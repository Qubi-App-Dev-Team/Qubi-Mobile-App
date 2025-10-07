from utils.firebase_reader import listen_for_circuits
from utils.create_circuit import create_circuit
from utils.send_ionq import get_ionq_results

def process_circuit(doc_id, gates, num_qubits, num_clbits):
    qc = create_circuit(gates, num_qubits, num_clbits)
    print(f"\n[{doc_id}] Created Circuit:\n{qc}\n")
    get_ionq_results(qc, shots=1000, backend_name="ionq_simulator", create_plot=True, save_plot=f"results/histogram_{doc_id}.png")

listen_for_circuits(process_circuit)