from utils_new.send_ionq import get_ionq_results
from utils_new.send_ibm import get_ibm_results
from qiskit import QuantumCircuit

# circuit -> shots -> backend_name -> job results to send to firebase

# unified results:
# key: example
# provider: ionq, ibm
# backend_name: ionq_simulator, least busy backend name
# job_id: None
# shots: 1000
# n_qubits: 10
# counts: {state: count}
# probabilities: {state: probability}

def get_circuit_results(circuit: QuantumCircuit, shots: int = 1000, quantum_computer_type: str = "ionq", backend_name: str = "ionq_simulator", user_info: dict[str, any] = None):
    success = True
    try:
        if quantum_computer_type == 'ionq':
            print("++++++++++++++++++++++++++++++++++++++++++++++++++++")
            result = get_ionq_results(circuit, shots, backend_name = backend_name, api_token = user_info['ionq_api_tok'])
        elif quantum_computer_type == 'ibm':
            print("++++++++++++++++++++++++++++++++++++++++++++++++++++")
            result = get_ibm_results(circuit, shots, backend_name = backend_name, api_token = user_info['ibm_api_tok'])
        else:
            raise ValueError("Invalid quantum computer type")
    except Exception as e:
        success = False
        result = {}
    result.update({
        "success": success
    })

    return result
