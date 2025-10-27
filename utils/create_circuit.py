from qiskit import QuantumCircuit

def create_circuit(gates, num_qubits, num_clbits):
    try:
        qc = QuantumCircuit(num_qubits, num_clbits)
    except Exception as e:
        raise ValueError(f"Failed to create quantum circuit with {num_qubits} qubits and {num_clbits} classical bits: {str(e)}")

    for i, gate in enumerate(gates):
        try:
            gate_name = gate.get('name')

            if not gate_name:
                raise ValueError(f"Gate at index {i} is missing 'name' field")

            if gate_name == "h":
                qc.h(*gate['qubits'])
            elif gate_name == "x":
                qc.x(*gate['qubits'])
            elif gate_name == "y":
                qc.y(*gate['qubits'])
            elif gate_name == "z":
                qc.z(*gate['qubits'])
            elif gate_name == "t":
                qc.t(*gate['qubits'])
            elif gate_name == "tdg":
                qc.tdg(*gate['qubits'])
            elif gate_name == "cx":
                qc.cx(*gate['qubits'])
            elif gate_name == "cz":
                qc.cz(*gate['qubits'])
            elif gate_name == "rz":
                if 'params' not in gate or len(gate['params']) == 0:
                    raise ValueError(f"RZ gate at index {i} is missing required parameter")
                qc.rz(gate['params'][0], *gate['qubits'])
            elif gate_name == "measure":
                if 'clbits' not in gate:
                    raise ValueError(f"Measure gate at index {i} is missing 'clbits' field")
                qc.measure(gate['qubits'], gate['clbits'])
            else:
                raise ValueError(f"Unsupported gate '{gate_name}' at index {i}")

        except KeyError as e:
            raise ValueError(f"Gate at index {i} ('{gate.get('name', 'unknown')}') is missing required field: {str(e)}")
        except TypeError as e:
            raise ValueError(f"Gate at index {i} ('{gate.get('name', 'unknown')}') has invalid qubit/clbit specification: {str(e)}")
        except Exception as e:
            raise ValueError(f"Failed to apply gate '{gate.get('name', 'unknown')}' at index {i}: {str(e)}")

    return qc