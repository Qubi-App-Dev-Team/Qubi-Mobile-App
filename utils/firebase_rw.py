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

def add_results_new(results):
    """
    Add results to the 'runs_results' collection.
    """
    runs_ref = db.collection('runs_results')
    
    doc_id = results.pop('run_request_id')
    new_run = runs_ref.document(doc_id)

    results.update({
        'created_at': firestore.SERVER_TIMESTAMP,
    })

    new_run.set(results)
    return new_run.id

def add_results(doc_id, elapsed_time, results):
    """
    Add results to the 'runs' collection with a random document ID.

    Args:
        doc_id: The circuit document ID that was executed
        results: The results from the quantum execution (Qiskit Result object)
    """
    # runs_ref = db.collection('runs')
    runs_ref = db.collection('runs_results')

    # Create a new document with auto-generated ID
    new_run = runs_ref.document()

    # Extract only the backend name and counts for Firestore compatibility
    data = {
        'circuit_id': doc_id,
        'quantum_computer': results.backend_name,
        'histogram': results.get_counts(),
        'total_runtime': round(elapsed_time, 2),
        'run_datetime': firestore.SERVER_TIMESTAMP
    }

    # Set the data
    new_run.set(data)

    print(f"Results added to 'runs' collection with ID: {new_run.id}")
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

def listen_for_circuits(callback):
    """
    Listen for new circuit documents and call the callback function when one is added.

    Args:
        callback: Function that takes (doc_id, gates, num_qubits, num_clbits)
    """
    def on_snapshot(_col_snapshot, changes, _read_time):
        for change in changes:
            if change.type.name == 'ADDED':
                doc = change.document
                doc_id = doc.id

                if doc_id not in processed_docs:
                    processed_docs.add(doc_id)

                    data = doc.to_dict()
                    gates = data.get('gates')
                    num_qubits = data.get('num_qubits')
                    num_clbits = data.get('num_clbits')

                    if gates is not None and num_qubits is not None and num_clbits is not None:
                        callback(doc_id, gates, num_qubits, num_clbits)

    print("Starting Firebase listener for 'circuits' collection...")
    print("Waiting for new documents...\n")

    col_ref = db.collection('circuits')
    col_watch = col_ref.on_snapshot(on_snapshot)

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\nStopping listener...")
        col_watch.unsubscribe()