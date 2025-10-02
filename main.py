from firebase_reader import get_circuit

gates, num_qubits, num_clbits = get_circuit()

print(gates, num_qubits, num_clbits)