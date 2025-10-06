from firebase_reader import get_circuit
from create_circuit import create_circuit

gates, num_qubits, num_clbits = get_circuit()

print(gates, num_qubits, num_clbits)
print(create_circuit(gates, num_qubits, num_clbits))