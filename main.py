import time
import os

from utils.firebase_rw import get_circuit_by_id, add_results, add_results_new
from utils.create_circuit import create_circuit
from utils.send_qc import get_circuit_results

def send_circuit(
    run_request_id: str,
    user_id: str,
    circuit_id: str,
    circuit: dict[str, any],
    quantum_computer_type: str,
    shots: int
):
    print(f"Fetching circuit '{circuit_id}' from Firebase...")

    # Get circuit data from Firebase
    circuit_data = get_circuit_by_id(circuit_id)
    if circuit_data is None:
        return None

    gates, num_qubits, num_clbits = circuit_data
    # gates, num_qubits, num_clbits = circuit
    print(f"Creating circuit...")
    qc = create_circuit(gates, num_qubits, num_clbits)

    print(f"Running circuit on {quantum_computer_type}...")
    start_time = time.perf_counter()
    res = get_circuit_results(qc, shots=shots, quantum_computer_type=quantum_computer_type)
    elapsed_time = time.perf_counter() - start_time

    if res is None:
        print("Failed to get results from quantum computer")
        return None

    res.update({
        "elapsed_time": elapsed_time,
        "run_request_id": run_request_id,
        "user_id": user_id,
        "circuit_id": circuit_id,
    })
    
    print(f"Results: {res}")

    print(f"Saving results to Firebase...")
    run_id = add_results_new(res)
    print("run_id: ", run_id)

    return run_id


""" quantum_computer_name options:
        ionq: 'ionq_simulator'
        ibm: ''
"""
def main(circuit_id, quantum_computer_name):
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
    res = get_circuit_results(qc, shots=shots, quantum_computer_type=quantum_computer_type)
    elapsed_time = time.perf_counter() - start_time

    

    if res is None:
        print("Failed to get results from quantum computer")
        return None
    # Save results to Firebase
    print(f"Results: {res}")

    res = parse_sampler_result(res)
    print(f"Parsed results: {res}")
    
    run_id = add_results(circuit_id, elapsed_time, res)
    print(f"\nCompleted successfully in {elapsed_time:.2f} seconds")

    return run_id

# main('5x24CbCFtflbJHA8ldaD', 'ionq')
# main('5x24CbCFtflbJHA8ldaD', 'ibm')
send_circuit('123', '456', '5x24CbCFtflbJHA8ldaD', '101', 'ionq', 1000)
send_circuit('123', '456', '5x24CbCFtflbJHA8ldaD', '101', 'ibm', 1000)