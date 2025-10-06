from qiskit import QuantumCircuit

def create_circuit(gates, num_qubits, num_clbits):
    qc = QuantumCircuit(num_qubits, num_clbits)
    for gate in gates:

        if gate['name'] == "h":
            qc.h(*gate['qubits'])
        elif gate['name'] == "x":
            qc.x(*gate['qubits'])
        elif gate['name'] == "cx":
            qc.cx(*gate['qubits'])
        elif gate['name'] == "rz":
            qc.rz(gate['params'][0], *gate['qubits'])
        elif gate['name'] == "measure":
            qc.measure(gate['qubits'], gate['clbits'])
        
    return qc