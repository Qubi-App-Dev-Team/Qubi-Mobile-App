from firebase_reader import get_circuit
from create_circuit import create_circuit
from send_ionq import get_ionq_results

gates, num_qubits, num_clbits = get_circuit()

print(gates, num_qubits, num_clbits)
print(create_circuit(gates, num_qubits, num_clbits))

print(get_ionq_results(create_circuit(gates, num_qubits, num_clbits), shots=1000, backend_name="ionq_simulator", create_plot=True, save_plot="histogram.png"))