import time
import os
import traceback

from utils.firebase_rw import add_results, add_error_result
from utils.create_circuit import create_circuit
from utils.send_ionq import get_ionq_results
from utils.send_ibm import get_ibm_results
from typing import Any, Dict, Optional, List

""" quantum_computer_name options:
        ionq: 'ionq_simulator'
        ibm: ''
"""
def send_circuit(run_request_id: str, user_id: str, circuit_id: str, circuit: dict[str, any], quantum_computer: str, shots: int, api_keys: Optional[Dict[str, str]] = None):
    start_time = time.perf_counter()

    try:
        # Convert circuit into sendable format
        gates = circuit.get("gates")
        num_qubits = circuit.get("num_qubits")
        num_clbits = circuit.get("num_clbits")
        print(f"Creating circuit...")
        qc = create_circuit(gates, num_qubits, num_clbits)

        # Create results folder if nonexistent
        os.makedirs("results", exist_ok=True)
        print(f"Running circuit on {quantum_computer}...")

        # Extract user-provided API keys if available
        ionq_api_key = api_keys.get('ionq') if api_keys else None
        ibm_api_key = api_keys.get('ibm') if api_keys else None

        res = None
        if quantum_computer == 'ionq_simulator':
            res = get_ionq_results(qc, shots=shots, backend_name=quantum_computer, create_plot=True, save_plot=f"results/histogram_ionq{circuit_id}.png", api_token=ionq_api_key)
        elif quantum_computer == 'ibm_simulator':
            res = get_ibm_results(qc, shots=shots, backend_name="simulator_stabilizer", create_plot=True, save_plot=f"results/histogram_ibm{circuit_id}.png", api_token=ibm_api_key)
        else:
            error_msg = f"Invalid quantum computer name: {quantum_computer}. Use ionq_simulator or ibm_simulator"
            print(f"[ERROR] {error_msg}")
            elapsed_time = time.perf_counter() - start_time
            add_error_result(run_request_id, user_id, circuit_id, elapsed_time, shots, quantum_computer, error_msg)
            return None

        elapsed_time = time.perf_counter() - start_time

        if res is None:
            error_msg = "Failed to get results from quantum computer - execution returned None"
            print(f"[ERROR] {error_msg}")
            add_error_result(run_request_id, user_id, circuit_id, elapsed_time, shots, quantum_computer, error_msg)
            return None

        print(f"Saving results to Firebase...")
        run_id = add_results(run_request_id, user_id, circuit_id, elapsed_time, shots, res)
        print(f"\nCompleted successfully in {elapsed_time:.2f} seconds")
        return run_id

    except Exception as e:
        elapsed_time = time.perf_counter() - start_time
        error_msg = f"{type(e).__name__}: {str(e)}"
        print(f"[ERROR] Exception during circuit execution: {error_msg}")
        print(traceback.format_exc())

        # Save error result to Firestore so frontend knows the run failed
        try:
            add_error_result(run_request_id, user_id, circuit_id, elapsed_time, shots, quantum_computer, error_msg)
            print(f"Error result saved to Firebase for run_request_id: {run_request_id}")
        except Exception as fb_error:
            print(f"[ERROR] Failed to save error result to Firebase: {fb_error}")

        return None