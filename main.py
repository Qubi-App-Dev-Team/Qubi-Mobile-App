from utils.firebase_reader import get_circuit
from utils.create_circuit import create_circuit
from utils.send_ionq import get_ionq_results

gates, num_qubits, num_clbits = get_circuit()
qc = create_circuit(gates, num_qubits, num_clbits)

print(f"Created Circuit:\n{qc}\n")

get_ionq_results(qc, shots=1000, backend_name="ionq_simulator", create_plot=True, save_plot="results/histogram.png")