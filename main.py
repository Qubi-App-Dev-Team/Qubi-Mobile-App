import time

from utils.firebase_rw import get_circuit_by_id, add_results
from utils.create_circuit import create_circuit
from utils.send_ionq import get_ionq_results

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

    # Run the circuit on the specified quantum computer
    print(f"Running circuit on {quantum_computer_name}...")
    start_time = time.perf_counter()
    res = get_ionq_results(qc, shots=1000, backend_name=quantum_computer_name, create_plot=True, save_plot=f"results/histogram_{circuit_id}.png")
    elapsed_time = time.perf_counter() - start_time

    if res is None:
        print("Failed to get results from quantum computer")
        return None

    # Save results to Firebase
    run_id = add_results(circuit_id, elapsed_time, res)
    print(f"\nCompleted successfully in {elapsed_time:.2f} seconds")

    return run_id

main('5x24CbCFtflbJHA8ldaD', 'ionq_simulator')