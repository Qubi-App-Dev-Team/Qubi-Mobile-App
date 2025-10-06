import firebase_admin
from firebase_admin import firestore, credentials
import os, json
from dotenv import load_dotenv

# it prints error message but that should be fine

# Env creds
load_dotenv()
firebase_creds_str = os.environ.get("FIREBASE_CREDENTIALS")
firebase_creds_dict = json.loads(firebase_creds_str)
cred = credentials.Certificate(firebase_creds_dict)

# init and create app
app = firebase_admin.initialize_app(cred)
db = firestore.client()

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

# Reading
runs = db.collection("runs").stream()
count = 1
for run in runs:
    print(f"{run.id} => {count}")
    count += 1

# Updating
document = db.collection("runs").document("testing")
document.update({
    "depth": 20,
    "quantum_computer": "IonQ",
})

# Deleting
db.collection("runs").document("testing").update({
    "results": firestore.DELETE_FIELD
})

db.collection("runs").document("todelete").delete()

