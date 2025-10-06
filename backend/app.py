import firebase_admin
from firebase_admin import firestore, credentials
import os, json
from dotenv import load_dotenv

# Env creds
load_dotenv()
firebase_creds_str = os.environ.get("FIREBASE_CREDENTIALS")
firebase_creds_dict = json.loads(firebase_creds_str)
cred = credentials.Certificate(firebase_creds_dict)

# init and create app
app = firebase_admin.initialize_app(cred)
db = firestore.client()

doc_ref = db.collection("users").document("brotest")
doc_ref.set({"middle": "Ada", "quarter": "Lovelace", "day": "september"})

doc_ref = db.collection("users").document("aturing")
doc_ref.set({"first": "Alan", "middle": "Mathison", "last": "Turing", "born": 1912})
