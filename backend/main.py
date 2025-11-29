# main.py
#   - POST /make_request
#   - GET  /fetch_results
#   - GET  /fetch_run_history
import os
import json
import hashlib
from typing import Any, Dict, Optional, List
from datetime import datetime, timezone
import firebase_admin
from firebase_admin import credentials, firestore
from fastapi import FastAPI, HTTPException, BackgroundTasks
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field
from dotenv import load_dotenv
from google.cloud.firestore_v1 import DocumentSnapshot
from google.cloud.firestore_v1._helpers import DatetimeWithNanoseconds
from datetime import datetime
# send_circuit()
from quantum import send_circuit

# Models
class MakeRequestDTO(BaseModel):
    user_id: str
    shots: int = Field(gt=0)
    circuit: Dict[str, Any]               
    quantum_computer: str   

# App & Firestore init
load_dotenv()
firebase_creds = os.getenv("FIREBASE_CREDENTIALS")
if not firebase_creds:
    raise RuntimeError("FIREBASE_CREDENTIALS env var is missing.")
firebase_creds_dict = json.loads(firebase_creds)
cred = credentials.Certificate(firebase_creds_dict)
if not firebase_admin._apps:
    firebase_admin.initialize_app(cred)
db = firestore.client()
app = FastAPI(title="Qubi MVP API", version="0.1.0")

              
# Helpers
def serialize_value(value):
    """Recursively converts Firestore timestamps and nested objects into JSON-safe types."""
    if isinstance(value, DatetimeWithNanoseconds):
        return value.isoformat()
    elif isinstance(value, dict):
        return {k: serialize_value(v) for k, v in value.items()}
    elif isinstance(value, list):
        return [serialize_value(v) for v in value]
    else:
        return value

def canonicalize_and_hash(circuit: Dict[str, Any]) -> str:
    """Deterministically hash the circuit JSON (keys sorted) exactly as provided."""
    canonical_json = json.dumps(circuit, sort_keys=True, separators=(",", ":"))
    return hashlib.sha256(canonical_json.encode("utf-8")).hexdigest()

def circuit_exists(circuit_id: str) -> bool:
    """Return True if circuits/{circuit_id} exists."""
    return db.collection("circuits").document(circuit_id).get().exists

def insert_circuit(circuit_dict: Dict[str, Any]) -> str:
    circuit_id = canonicalize_and_hash(circuit_dict)
    if not circuit_exists(circuit_id):
        db.collection("circuits").document(circuit_id).set(circuit_dict)
    return circuit_id


# Endpoints

@app.post("/make_request")
async def make_request(dto: MakeRequestDTO, bg: BackgroundTasks):
    """
    1) Insert circuit into circuits/{circuit_id}
    2) Create run_requests/{run_request_id} and write to db
    3) Asynchronously call send_circuit function
    4) Return run_request_id
    """
    try:
        circuit_id = insert_circuit(dto.circuit)
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Invalid circuit payload: {e}")

    req_ref = db.collection("run_requests").document()
    run_request_id = req_ref.id

    req_ref.set({
        "user_id": dto.user_id,
        "shots": dto.shots,
        "circuit_id": circuit_id,
        "quantum_computer": dto.quantum_computer,
        "created_at": firestore.SERVER_TIMESTAMP,
        "status": "PENDING",
    })

    bg.add_task(
        send_circuit,                 
        run_request_id,               
        dto.user_id,                 
        circuit_id,                      
        dto.circuit,                  
        dto.quantum_computer,         
        dto.shots,                 
    )
    print("run_request_id" + str(run_request_id))
    return {"run_request_id": run_request_id}


@app.get("/fetch_results")
async def fetch_results(run_request_id: str):
    '''
    Fetch results of a request with id run_request_id
    '''

    # If result completed 
    result_snap = db.collection("run_results").document(run_request_id).get()
    if result_snap.exists:
        result = serialize_value(result_snap.to_dict())
        return JSONResponse(
            status_code=200,
            content={"status": "completed", "run_result": result}
        )

    # If request created but result not completed yet 
    request_snap = db.collection("run_requests").document(run_request_id).get()
    if request_snap.exists:
        request_data = serialize_value(request_snap.to_dict())
        qc = request_data.get("quantum_computer")
        shots = request_data.get("shots")
        return JSONResponse(
            status_code=202,
            content={
                "status": "waiting for quantum computer",
                "quantum_computer": qc,
                "shots": shots
            }
        )

    # Not found at all
    return JSONResponse(
        status_code=404,
        content={"status": f"request with id {run_request_id} does not exist"}
    )


@app.get("/fetch_run_history")
async def fetch_run_history(user_id: str, limit: int = 20):
    """
    Fetches completed runs for a given user from run_results.
    Returns all fields, fully serialized for frontend display.
    """
    q = (
        db.collection("run_results")
        .where("user_id", "==", user_id)
        .order_by("created_at", direction=firestore.Query.DESCENDING)
        .limit(limit)
    )

    docs = list(q.stream())
    history: List[Dict[str, Any]] = []

    for d in docs:
        obj = serialize_value(d.to_dict() or {})
        # Append the entire serialized document, keeping consistent shape
        history.append(obj)

    return JSONResponse(status_code=200, content={"history": history})

@app.get("/fetch_last_shake/{user_id}")
async def fetch_last_shake(user_id: str):
    """
    Returns the most recent run_result document for a given user.
    Includes all fields exactly as stored in Firestore.
    """

    try:
        # Query the latest run_result by creation time
        print('trying')
        query = (
            db.collection("run_results")
            .where("user_id", "==", user_id)
            .where("success", "==", True)
            .order_by("created_at", direction=firestore.Query.DESCENDING)
            .limit(1)
            .stream()
        )
        doc = next(query, None)
        print('trying1')
        if not doc:
            return {"status": "NONE", "message": "No completed runs found"}

        data = doc.to_dict()
        data["run_result_id"] = doc.id  # Optional helper field

        # Convert Firestore timestamp to ISO string
        created_at = data.get("created_at")
        if created_at:
            try:
                data["created_at"] = created_at.isoformat()
            except Exception:
                pass  # If it's already a string, skip conversion

        return data

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))



'''
{
  "user_id": "user_01",
  "shots": 1000,
  "quantum_computer": "ionq_simulator",
  "circuit": {
    "gates": [
      {"name": "h", "qubits": [0]},
      {"name": "cx", "qubits": [0, 1]},
      {"name": "measure", "qubits": [0, 1], "clbits": [0, 1]}
    ],
    "num_qubits": 2,
    "num_clbits": 2
  }
}

{
  "status": "waiting for quantum computer",
  "quantum_computer": "ionq_simulator",
  "shots": 1000
}


{
  "status": "completed",
  "run_result": {
    "histogram_probabilities": {
      "11": 0.5,
      "00": 0.5
    },
    "created_at": "2025-11-03T23:48:59.895000+00:00",
    "histogram_counts": {
      "11": 523,
      "00": 477
    },
    "quantum_computer": "ionq_simulator",
    "shots": 1000,
    "elapsed_time_s": 6.612540625035763,
    "user_id": "user_01",
    "success": true,
    "circuit_id": "6d8fc29c2a6e5d38fa982cb418039810fcce60f77c887f0aeef1fc1856236573"
  }
}


'''