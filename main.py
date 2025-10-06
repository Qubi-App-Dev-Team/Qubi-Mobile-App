from firebase_reader import get_circuit, make_circuit

gates, num_qubits, num_clbits = get_circuit()

print(gates, num_qubits, num_clbits)
print(make_circuit(gates, num_qubits, num_clbits))