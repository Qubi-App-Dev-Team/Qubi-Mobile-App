import os
from dotenv import load_dotenv
from qiskit import QuantumCircuit, transpile
from qiskit_ibm_runtime import QiskitRuntimeService, SamplerV2 as Sampler
from qiskit_ibm_runtime.accounts.exceptions import AccountAlreadyExistsError

load_dotenv()


def get_ibm_results(circuit: QuantumCircuit, shots: int = 1000, backend_name: str = "simulator_stabilizer", api_token: str = None):

    try:
        result, backend_name_final = send_to_ibm(circuit, shots, backend_name, api_token)
        
        counts = get_counts_from_primitive_result(result)
        probabilities = {k: v / shots for k, v in counts.items()}
        
        print(f"\nResults from IBM {backend_name} ({shots} shots):")
        print("=" * 50)
        for state, count in counts.items():
            prob = count / shots
            print(f"|{state}⟩: {prob:.4f} ({count} counts)")

        unified = {
            "provider": "ibm",
            "backend_name": backend_name_final,
            "shots": shots,
            "n_qubits": circuit.num_qubits,
            "counts": counts,
            "probabilities": probabilities,
        }

        return unified
    
    except Exception as e:
        print(f"Error sending circuit to IBM: {e}")
        return None

def send_to_ibm(circuit: QuantumCircuit, shots: int = 1000, backend_name: str = "default", api_token: str = None):

    try:
        if not api_token:
            raise Exception("IBM_API_TOKEN environment variable not set. Please set it in your .env file.")
        QiskitRuntimeService.save_account(channel="ibm_quantum_platform", token=api_token)
    except AccountAlreadyExistsError as e:
        pass
    except Exception as e:
        print(f"Error: {e}")

    service = QiskitRuntimeService(channel="ibm_quantum_platform")
    
    # may be the cause of the error:
    # Error sending circuit to IBM: 'No matching instances found for the following filters: .'
    backend = service.least_busy(operational=True, simulator=False)
    transpiled_qc = transpile(circuit, backend=backend, optimization_level=3)

    sampler = Sampler(backend)
    job = sampler.run([transpiled_qc])

    result = job.result()

    return result, backend.name

def get_counts_from_primitive_result(result):
    pub_result = result[0]
    data = pub_result.data

    counts = None
    for reg_name in ('c', 'meas'):
        if hasattr(data, reg_name):
            counts = getattr(data, reg_name).get_counts()
            break
    else:
        for attr_name in (a for a in dir(data) if not a.startswith('_')):
            attr = getattr(data, attr_name)
            if hasattr(attr, 'get_counts'):
                counts = attr.get_counts()
                break

    if counts is None:
        raise ValueError("No valid classical register with get_counts() found.")
    
    return counts