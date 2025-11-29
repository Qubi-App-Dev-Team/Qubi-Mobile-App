import time
import os

from utils.firebase_rw import add_results, get_user_info
from utils.create_circuit import create_circuit
from utils.send_qc import get_circuit_results

from dotenv import load_dotenv
import firebase_admin
from firebase_admin import credentials, firestore
import json
import os
import time



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

def send_circuit(
    run_request_id: str,
    user_id: str,
    circuit_id: str,
    circuit: dict[str, any],
    quantum_computer_type: str,
    shots: int
):
    success = True
    start_time = time.perf_counter()
    try:
        user_info = get_user_info(user_id)
        print(f"User info: {user_info}")

        gates = circuit.get("gates")
        num_qubits = circuit.get("num_qubits")
        num_clbits = circuit.get("num_clbits")

        print(f"Creating circuit...")
        qc = create_circuit(gates, num_qubits, num_clbits)

        db.collection("run_requests").document(run_request_id).update({
            "status": "RUNNING"
        })

        print(f"Running circuit on {quantum_computer_type}...")
        res = get_circuit_results(qc, shots=shots, quantum_computer_type=quantum_computer_type, user_info=user_info)

        if res is None:
            print("Failed to get results from quantum computer")
            raise ValueError("Invalid quantum computer type")
    
    except Exception as e:
        success = False
        res = {}
    
    elapsed_time = time.perf_counter() - start_time

    res.update({
        "success": success,
        "elapsed_time": elapsed_time,
        "run_request_id": run_request_id,
        "user_id": user_id,
        "circuit_id": circuit_id
    })

    print(f"Results: {res}")
    print(f"Saving results to Firebase...")
    run_id = add_results(res)
    print("run_id: ", run_id)

    return run_id

# Example usage

# send_circuit(
#     run_request_id="0J77V36f36AJqAT8MFIf",
#     user_id="YIcqRYGvenTVAMxpgwXPXA5rOyi2",
#     circuit_id="circuit_01",
#     circuit={
#         "gates": [{"name": "h", "qubits": [0]}, {"name": "cx", "qubits": [0, 1]}, {"name": "measure", "qubits": [0, 1], "clbits": [0, 1]}],
#         "num_qubits": 2,
#         "num_clbits": 2
#     },
#     quantum_computer_type="ionq",
#     shots=1000
# )