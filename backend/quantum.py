import time
import os

from utils.firebase_rw import get_circuit_by_id, add_results, add_results_new
from utils.create_circuit import create_circuit
from utils.send_ionq import get_ionq_results
from utils.send_ibm import get_ibm_results
from typing import Any, Dict, Optional, List

""" quantum_computer_name options:
        ionq: 'ionq_simulator'
        ibm: ''
"""
def send_circuit_old(circuit_id, quantum_computer_name):
    print(f"Fetching circuit '{circuit_id}' from Firebase...")

    # Get circuit data from Firebase
    circuit_data = get_circuit_by_id(circuit_id)
    if circuit_data is None:
        return None

    gates, num_qubits, num_clbits = circuit_data

    # Create the quantum circuit
    qc = create_circuit(gates, num_qubits, num_clbits)
    print(f"\n[{circuit_id}] Created Circuit:\n{qc}\n")

    # Create results folder if nonexistent
    os.makedirs("results", exist_ok=True)

    # Run the circuit on the specified quantum computer
    print(f"Running circuit on {quantum_computer_name}...")
    start_time = time.perf_counter()
    
    if quantum_computer_name == 'ionq_simulator':
        res = get_ionq_results(qc, shots=1000, backend_name=quantum_computer_name, create_plot=True, save_plot=f"results/histogram_ionq{circuit_id}.png")
    else:
        res = get_ibm_results(qc, shots=1000, backend_name="simulator_stabilizer", create_plot=True, save_plot=f"results/histogram_ibm{circuit_id}.png")

    elapsed_time = time.perf_counter() - start_time

    if res is None:
        print("Failed to get results from quantum computer")
        return None

    # Save results to Firebase
    run_id = add_results(circuit_id, elapsed_time, res)
    print(f"\nCompleted successfully in {elapsed_time:.2f} seconds")

    return run_id, elapsed_time, res


def send_circuit(run_request_id: str, user_id: str, circuit_id: str, circuit: dict[str, any], quantum_computer: str, shots: int):

    print(f"Fetching circuit '{circuit_id}' from Firebase...")
    circuit_data = get_circuit_by_id(circuit_id)
    if circuit_data is None:
        return None
    
    gates, num_qubits, num_clbits = circuit_data
    print(f"Creating circuit...")
    qc = create_circuit(gates, num_qubits, num_clbits)
    
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
    elapsed_time = time.perf_counter() - start_time
    
    if res is None:
        print("Failed to get results from quantum computer")
        return None
    
    print(f"Saving results to Firebase...")
    run_id = add_results_new(run_request_id, user_id, circuit_id, elapsed_time, shots, res)
    print(f"\nCompleted successfully in {elapsed_time:.2f} seconds")
    return run_id
#main('5x24CbCFtflbJHA8ldaD', 'ionq_simulator')