import firebase_admin
from pydantic import BaseModel
from typing import Optional, Dict, Literal
from firebase_admin import firestore, credentials
import os, json
from dotenv import load_dotenv
from fastapi import FastAPI

from quantum import send_circuit
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import hashlib
import json
import requests

app = FastAPI()


class ExecuteShakeRequest(BaseModel):
    user_id: str
    circuit: dict
    quantum_computer: str
    circuit_name: str | None = None

# Dictionary for all time options
class Time(BaseModel):
    total: int
    execution: int
    pending: int

# Dictionary for histogram results - assuming 2 qubits
class Model(BaseModel):
    first: float    # 0001
    second: float   # 0010
    third: float    # 0100
    fourth: float   # 1000

# Each item in circuit
class Gate(BaseModel):
    name: str
    qubit: list[int]

# Last item in circuit - measurement
class Measurement(BaseModel):
    name: Literal["measure"]
    qubit: list[int]
    classical: list[int]

# Schema for each run
class Run(BaseModel):
    circuit_id: str
    depth: int
    result: int
    time: Time
    per_shot: int
    quantum_computer: str
    histogram: Model

# Schema for circuit to store in db
class Circuit(BaseModel):
    gates: list[Gate]
    # name: str
    classical: int
    qubit: int
    measure: Measurement

# Env creds
load_dotenv()
firebase_creds = os.getenv("FIREBASE_CREDENTIALS")
firebase_creds_dict = json.loads(firebase_creds)
cred = credentials.Certificate(firebase_creds_dict)

# init and create app
if not firebase_admin._apps:
    application = firebase_admin.initialize_app(cred)
else:
    application = firebase_admin.get_app()

#application = firebase_admin.initialize_app(cred)
db = firestore.client()

# Posting a run
@app.post("/run") 
async def post_run(run: Run):
    ref = db.collection("runs").document()
    ref.set({
        "circuit_id": run.circuit_id,
        "depth": run.depth,
        "results": run.result,
        "time": {
            "total": run.time.total,
            "execution": run.time.execution,
            "pending": run.time.pending,
        },
        "per_shot": run.per_shot,
        "quantum_computer": run.quantum_computer,
        "histogram": {
            "0001": run.histogram.first,
            "0010": run.histogram.second,
            "0100": run.histogram.third,
            "1000": run.histogram.fourth,
        },
    })
    return {"message": f"It posted to website. {ref.id}"}

# Posting a circuit
@app.post("/circuit") 
async def post_circuit(circuit: Circuit):
    circuit.gates.append(circuit.measure) # Adding measurement to last gates list
    ref = db.collection("circuits").document().set({
        "gates": [
            {
                "name": gate.name,
                "qubits": gate.qubit,
                **({"clbits": gate.classical} if gate.name == "measure" else {})
            } for gate in circuit.gates
        ],
        "name": circuit.name,
        "num_clbits": circuit.classical,
        "num_qubits": circuit.qubit,
    })
    return {"message": "Posted a new circuit."}

@app.post("/circuit/{hash_id}")
async def post_circuit(hash_id: str, circuit: Circuit):
    """
    Inserts a circuit into Firestore using a provided hash_id as the document ID.
    Automatically appends the measurement gate before storing.
    """
    # Add the measurement gate as the last gate
    circuit.gates.append(circuit.measure)

    # Create the Firestore document under the given hash_id
    db.collection("circuits").document(hash_id).set({
        "gates": [
            {
                "name": gate.name,
                "qubits": gate.qubit,
                **({"clbits": gate.classical} if gate.name == "measure" else {})
            } for gate in circuit.gates
        ],
        "num_clbits": circuit.classical,
        "num_qubits": circuit.qubit,
    })

    return {"message": f"Circuit {hash_id} inserted successfully."}

# Read a run
@app.get("/runs/{identifier}")
async def get_run(identifier: str):
    run = db.collection("runs").document(identifier).get()
    if run.exists:
        return run.to_dict()
    else:
        return {"error": "Run not found"}

# Read a circuit
@app.get("/circuits/{identifier}")
async def get_circuit(identifier: str):
    circuit = db.collection("circuits").document(identifier).get()
    if circuit.exists:
        return circuit.to_dict()
    else:
        return {"error": "Circuit not found"}

# Updating a run
@app.put("/runs/{identifier}/{field}/{value}")
async def update_run(identifier: str, field: str, value: str):
    document = db.collection("runs").document(identifier)
    document.update({
        field: value
    })
    return {"message": "It worked"}

# Updating a circuit
@app.put("/circuits/{identifier}/{field}/{value}")
async def update_circuit(identifier: str, field: str, value: str):
    document = db.collection("circuits").document(identifier)
    document.update({
        field: value
    })
    return {"message": "It worked"}

# Deleting a run
@app.delete("/runs/{identifier}") 
async def delete_run(identifier: str):
    db.collection("runs").document(identifier).delete()
    return {"message": f"{identifier} is gone"}

# Deleting a circuit
@app.delete("/circuits/{identifier}") 
async def delete_circuit(identifier: str):
    db.collection("circuits").document(identifier).delete()
    return {"message": f"{identifier} is gone"}


def circuit_exists(hash_id: str) -> bool:
    """
    Checks if a circuit document with the given hash_id exists in Firestore.
    """
    doc_ref = db.collection("circuits").document(hash_id)
    return doc_ref.get().exists


def canonicalize_and_hash(circuit: dict) -> str:
    """
    Converts a canonical circuit dict into a sorted JSON string
    then computes a deterministic SHA-256 hash.
    """
    canonical_json = json.dumps(circuit, sort_keys=True)
    return hashlib.sha256(canonical_json.encode()).hexdigest()



@app.post("/execute_shake")
async def execute_shake_endpoint(request: ExecuteShakeRequest):
    """
    1. Hash circuit
    2. Check if it exists in Firestore (via circuit_exists)
    3. If not, post it to /circuit/{hash_id}
    4. Call execution function
    """

    circuit = request.circuit
    quantum_computer = request.quantum_computer
    circuit_name = request.circuit_name

    # 1. Hash circuit
    hash_id = canonicalize_and_hash(circuit)
    print(f"Computed hash: {hash_id}")

    # 2. Check if circuit exists
    try:
        exists = circuit_exists(hash_id)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error checking Firestore: {e}")

    # 3. Post circuit if it doesn't exist
    if not exists:
        print("Circuit not found. Posting to Firestore...")

        try:
            # Call the internal function directly
            response = await post_circuit(hash_id, Circuit(**circuit))
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Failed to post circuit: {e}")

        print("Circuit successfully posted to Firestore.")
    else:
        print("Circuit already exists. Skipping insert.")


    # 4. Call joey's function to do a run 
    run_id, elapsed_time, res = send_circuit(hash_id, quantum_computer)

    # Convert IonQResult to plain dictionary
    res_dict = res.to_dict()

    data = res_dict["results"][0]["data"]

    # Extract counts
    counts = data["counts"]
    histogram_counts = [{k: v} for k, v in counts.items()]

    # Extract probabilities
    probabilities = data["probabilities"]
    histogram_probabilities = [{k: v} for k, v in probabilities.items()]

    # Build response
    return {
        "success": res_dict["success"],
        "circuit_id": hash_id,
        "run_id": run_id,
        "quantum_computer": res_dict["backend_name"],
        "histogram_counts": histogram_counts,
        "histogram_probabilities": histogram_probabilities,
        "time": elapsed_time,
        "shots": res_dict["results"][0]["shots"]
}




'''
{
  "user_id": "dummy_id",
  "circuit": {
    "gates": [
      {"name": "h", "qubit": [0]},
      {"name": "cx", "qubit": [0, 1]}
    ],
    "classical": 2,
    "qubit": 2,
    "measure": {
      "name": "measure",
      "qubit": [0, 1],
      "classical": [0, 1]
    }
  },
  "quantum_computer": "ionq_simulator",
  "circuit_name": "Bell Shake 1"
}
'''