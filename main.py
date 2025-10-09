import time

from utils.firebase_rw import listen_for_circuits, add_results
from utils.create_circuit import create_circuit
from utils.send_ionq import get_ionq_results

def process_circuit(doc_id, gates, num_qubits, num_clbits):
    qc = create_circuit(gates, num_qubits, num_clbits)
    print(f"\n[{doc_id}] Created Circuit:\n{qc}\n")
    
    start_time = time.perf_counter()
    res = get_ionq_results(qc, shots=1000, backend_name="ionq_simulator", create_plot=True, save_plot=f"results/histogram_{doc_id}.png")
    elapsed_time = time.perf_counter() - start_time
    
    add_results(doc_id, elapsed_time, res)

listen_for_circuits(process_circuit)