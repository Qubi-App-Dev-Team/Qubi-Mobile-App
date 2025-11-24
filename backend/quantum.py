import time
import os

from utils.firebase_rw import add_results
from utils.create_circuit import create_circuit
from utils.send_ionq import get_ionq_results
from utils.send_ibm import get_ibm_results
from typing import Any, Dict, Optional, List


from dotenv import load_dotenv

import json
import os
import time

import firebase_admin
from firebase_admin import credentials, firestore

load_dotenv()

# Initialize Firebase Admin (local or env-based)
try:
    cred_dict = json.loads(os.getenv('FIREBASE_CREDENTIALS'))
    cred = credentials.Certificate(cred_dict)
except:
    cred = credentials.Certificate('service-account-key.json')

if not firebase_admin._apps:
    firebase_admin.initialize_app(cred)
db = firestore.client()

processed_docs = set()

""" quantum_computer_name options:
        ionq: 'ionq_simulator'
        ibm: ''
"""
def send_circuit(run_request_id: str, user_id: str, circuit_id: str, circuit: dict[str, any], quantum_computer: str, shots: int):

    # Convert circuit into sendable format
    gates = circuit.get("gates")
    num_qubits = circuit.get("num_qubits")
    num_clbits = circuit.get("num_clbits")
    print(f"Creating circuit...")
    qc = create_circuit(gates, num_qubits, num_clbits)

    db.collection("run_requests").document(run_request_id).update({
        "status": "RUNNING"
    })
    
    # Create results folder if nonexistent
    os.makedirs("results", exist_ok=True)
    print(f"Running circuit on {quantum_computer}...")
    


    start_time = time.perf_counter()
    if quantum_computer == 'ionq_simulator':
        res = get_ionq_results(qc, shots=shots, backend_name=quantum_computer, create_plot=True, save_plot=f"results/histogram_ionq{circuit_id}.png")
    elif quantum_computer == 'ibm_simulator':
        res = get_ibm_results(qc, shots=shots, backend_name="simulator_stabilizer", create_plot=True, save_plot=f"results/histogram_ibm{circuit_id}.png")
    else:
        print("[ERROR] quantum computer name invalid: either use ionq_simulator or ibm_simulator")
    elapsed_time = time.perf_counter() - start_time # Calculate total time since we sent to qc
    
    if res is None:
        print("Failed to get results from quantum computer")
        return None
    
    print(f"Saving results to Firebase...")
    run_id = add_results(run_request_id, user_id, circuit_id, elapsed_time, shots, res)
    db.collection("run_requests").document(run_request_id).update({
        "status": "COMPLETED"
    })
    print(f"\nCompleted successfully in {elapsed_time:.2f} seconds")
    return run_id