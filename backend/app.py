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
    name: str
    classical: int
    qubit: int
    measure: Measurement

# Env creds
load_dotenv()
firebase_creds = os.getenv("FIREBASE_CREDENTIALS")
firebase_creds_dict = json.loads(firebase_creds)
cred = credentials.Certificate(firebase_creds_dict)

# init and create app
application = firebase_admin.initialize_app(cred)
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
