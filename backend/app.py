import firebase_admin
from pydantic import BaseModel
from typing import Any, Dict, List, Optional, Union, Literal
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

# Dictionary for the type and content of a component (components will be used to build pages)
class Component(BaseModel):
    type: str
    content: Optional[Union[str, Dict[str, Any]]] = None

# Schema for a page in a section to store in db (each section stores a list of pages)
class Page(BaseModel):
    components: List[Component]

# Schema for a section in a chapter to store in db (each chapter stores a list of sections)
class Section(BaseModel):
    title: str
    description: str
    version: int
    # pages is a list of lists, where each inner list is a list of components
    pages: List[Page]

# Schema for lesson chapter to store in db 
class Chapter(BaseModel):
    title: str
    diff: str
    number: int 
    sections: List[Section]

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

# Posting a chapter - not sure if we'll need this but useful for testing purposes
@app.post("/chapters/{identifier}")
async def post_chapter(identifier: str, chapter: Chapter):
    ref = db.collection("chapters").document()
    ref.set(chapter.model_dump())
    return {"message": f"Posted chapter '{identifier}' successfully"}

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
    
# Read a chapter
@app.get("/chapters/{identifier}")
async def get_chapter(identifier: str):
    chapter = db.collection("chapters").document(identifier).get()
    if chapter.exists:
        return chapter.to_dict()
    else:
        return {"error": "Chapter not found"}

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

# Deleting a chapter - not sure if we'll need this but useful for testing purposes
@app.delete("/chapters/{identifier}") 
async def delete_chapter(identifier: str):
    db.collection("chapters").document(identifier).delete()
    return {"message": f"{identifier} is gone"}
