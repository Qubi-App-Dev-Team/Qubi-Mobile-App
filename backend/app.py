import firebase_admin
from pydantic import BaseModel
from typing import Optional, Dict, Literal
from firebase_admin import firestore, credentials
import os, json
from dotenv import load_dotenv
from fastapi import FastAPI

app = FastAPI()

# Dictionary for all time options
class Time(BaseModel):
    total: int
    execution: int
    pending: int

# Dictionary for histogram results - assuming 2 qubits
class Model(BaseModel):
    first: float 
    second: float
    third: float
    fourth: float

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
    name: str
    classical: int
    qubit: int
    measure: Measurement

# Env creds
load_dotenv()
firebase_creds_str = os.environ.get("FIREBASE_CREDENTIALS")
firebase_creds_dict = json.loads(firebase_creds_str)
cred = credentials.Certificate(firebase_creds_dict)

# init and create app
application = firebase_admin.initialize_app(cred)
db = firestore.client()

@app.post("/run") # Posting a run
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

@app.post("/circuit") # Posting a circuit
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

@app.get("/runs/{identifier}") # Reading
async def get_run(identifier: str):
    run = db.collection("runs").document(identifier).get()
    if run.exists:
        return run.to_dict()
    else:
        return {"error": "Run not found"}

@app.put("/runs/{identifier}/{field}/{value}") # Updating
async def update(identifier: str, field: str, value: str):
    document = db.collection("runs").document(identifier)
    document.update({
        "depth": depth,
        "quantum_computer": computer_name,
    })
    return {"message": "It worked"}

@app.delete("/runs/{identifier}") # Deleting item
async def delete_run(identifier: str):
    db.collection("runs").document(identifier).delete()

    return {"message": f"{identifier} is gone"}

