import firebase_admin
from firebase_admin import firestore, credentials
import os, json
from dotenv import load_dotenv
from fastapi import FastAPI

# it prints error message but that should be fine

app = FastAPI()

# Env creds
load_dotenv()
firebase_creds_str = os.environ.get("FIREBASE_CREDENTIALS")
firebase_creds_dict = json.loads(firebase_creds_str)
cred = credentials.Certificate(firebase_creds_dict)

# init and create app
application = firebase_admin.initialize_app(cred)
db = firestore.client()

@app.get("/")
async def root():
    return {"message": "Hello World"}

@app.post("/runs")
async def post_run():
    # Creation
    ref = db.collection("runs").document("todelete").set({
        "circuit_id": 1738,
        "depth": 10,
        "results": 101,
        "time": {
            "total": 10,
            "execution": 4,
            "pending": 6,
        },
        "per_shot": 100,
        "quantum_computer": "IBM",
    })
    return {"message": "It ran."}

@app.get("/runs/{id_number}")
async def get_run(id_number: str):
    # Reading
    run = db.collection("runs").document(id_number).get()
    if run.exists:
        return run.to_dict()
    else:
        return {"error": "Run not found"}

@app.put("/runs/{computer_name}/{depth}")
async def update_run(computer_name: str):
    # Updating
    document = db.collection("runs").document("testing")
    document.update({
        "depth": depth,
        "quantum_computer": computer_name,
    })
    return {"message": "It worked"}


@app.delete("/runs/{id_number}")
async def delete_run(id_number: int):
    # Deleting
    db.collection("runs").document(id_number).update({
        "results": firestore.DELETE_FIELD
    })

    db.collection("runs").document("todelete").delete()

    return {"message": "Deleted"}

