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

from collections import Counter
import numpy as np

def get_user_info(user_id):
    """
    Get user information from the 'users' collection.
    """
    users_ref = db.collection('Users')
    user = users_ref.document(user_id).get()
    return user.to_dict()

def add_results(results):
    """
    Add results to the 'runs_results' collection.
    """
    #runs_ref = db.collection('runs_results')
    runs_ref = db.collection('run_results')
    
    doc_id = results.pop('run_request_id')
    new_run = runs_ref.document(doc_id)

    results.update({
        'created_at': firestore.SERVER_TIMESTAMP,
    })
    new_run.set(results)
    db.collection("run_requests").document(doc_id).update({
        "status": "COMPLETED"
    })
    return new_run.id

def get_circuit_by_id(circuit_id):
    """
    Get a circuit document by its ID.

    Args:
        circuit_id: The ID of the circuit document to retrieve

    Returns:
        A tuple of (gates, num_qubits, num_clbits) or None if not found
    """
    doc_ref = db.collection('circuits').document(circuit_id)
    doc = doc_ref.get()

    if not doc.exists:
        print(f"Error: Circuit with ID '{circuit_id}' not found")
        return None

    data = doc.to_dict()
    gates = data.get('gates')
    num_qubits = data.get('num_qubits')
    num_clbits = data.get('num_clbits')

    if gates is None or num_qubits is None or num_clbits is None:
        print(f"Error: Circuit '{circuit_id}' is missing required fields")
        return None

    return (gates, num_qubits, num_clbits)
