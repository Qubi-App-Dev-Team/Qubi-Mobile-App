from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import hashlib
import json
import requests
from app import circuit_exists  

app = FastAPI()

# Base URL for FastAPI backend 
FIRESTORE_API_URL = "http://127.0.0.1:8000"


# Pydantic model for request body
class ExecuteShakeRequest(BaseModel):
    circuit: dict
    quantum_computer: str
    circuit_name: str | None = None


# 🔹 Helper functions
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
        print(f"Circuit not found. Posting to Firestore...")
        post_url = f"{FIRESTORE_API_URL}/circuit/{hash_id}"
        response = requests.post(post_url, json=circuit)

        if response.status_code != 200:
            raise HTTPException(
                status_code=response.status_code,
                detail=f"Failed to post circuit: {response.text}",
            )

        print("Circuit successfully posted to Firestore.")
    else:
        print(f"Circuit already exists. Skipping insert.")

    # 4. Call joey's function to do a run 
    # # main('5x24CbCFtflbJHA8ldaD', 'ionq_simulator') 
    # # main(hash_id, quantum_computer)

    return {
        "message": "execute_shake completed successfully",
        "hash_id": hash_id,
        "execution_result": "[Placeholder run id]",
    }
