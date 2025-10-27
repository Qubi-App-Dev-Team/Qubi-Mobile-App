import time
import os

from utils.firebase_rw import get_circuit_by_id, add_results
from utils.create_circuit import create_circuit
from utils.send_ionq import get_ionq_results
from utils.send_ibm import get_ibm_results

""" quantum_computer_name options:
        ionq: 'ionq_simulator'
        ibm: ''
"""
def send_circuit(circuit_id, quantum_computer_name):
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

#main('5x24CbCFtflbJHA8ldaD', 'ionq_simulator')