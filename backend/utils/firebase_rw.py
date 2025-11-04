from dotenv import load_dotenv

import json
import os
import time

import firebase_admin
from firebase_admin import credentials, firestore

load_dotenv()

try:
    # Option 1: Use environment variable (requires FIREBASE_CREDENTIALS to be set)
    cred_dict = json.loads(os.getenv('FIREBASE_CREDENTIALS'))
    cred = credentials.Certificate(cred_dict)
except:
    # Option 2: Use service account key file (recommended)
    cred = credentials.Certificate('service-account-key.json')

firebase_admin.initialize_app(cred)
db = firestore.client()

processed_docs = set()

def add_results(run_request_id, user_id, circuit_id, elapsed_time, shots, results):
    """
    Add results to the 'run_results' collection.
    Uses the same doc ID as the run_request.
    """
    runs_ref = db.collection('run_results').document(run_request_id)
    
    data = {
        "success": True,
        "circuit_id": circuit_id,
        "user_id": user_id,
        "quantum_computer": results.backend_name,
        "histogram_counts": results.get_counts(),
        "histogram_probabilities": results.get_probabilities(),
        "shots": shots,
        "elapsed_time_s": elapsed_time,
        "created_at": firestore.SERVER_TIMESTAMP
    }

    runs_ref.set(data)
    return run_request_id