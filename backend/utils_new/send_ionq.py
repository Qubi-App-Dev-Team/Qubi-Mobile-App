import os
import warnings
from dotenv import load_dotenv

from qiskit import QuantumCircuit
from qiskit_ionq import IonQProvider
from qiskit_ionq.exceptions import IonQTranspileLevelWarning

load_dotenv()

warnings.filterwarnings('ignore', category=IonQTranspileLevelWarning)

def get_ionq_results(circuit: QuantumCircuit, shots: int = 1000, backend_name: str = "ionq_simulator", api_token: str = None):
    try:
        result = send_to_ionq(circuit, shots, backend_name, api_token)
        counts = result.get_counts()
        probabilities = result.get_probabilities()
        quantum_computer_type = 'ionq'
        quantum_computer_name = backend_name

        unified = {
            "provider": quantum_computer_type,
            "backend_name": quantum_computer_name,
            "shots": shots,
            "n_qubits": circuit.num_qubits,
            "counts": counts,
            "probabilities": probabilities,
        }

        return unified

    except Exception as e:
        print(f"Error sending circuit to IonQ: {e}")
        return None

def send_to_ionq(circuit: QuantumCircuit, shots: int = 1000, backend_name: str = "ionq_simulator", api_token: str = None):

    if not api_token:
        raise ValueError("IONQ_API_TOKEN environment variable not set. Please set it in your .env file.")
    
    provider = IonQProvider(token=api_token)
    backend = provider.get_backend(backend_name)
    job = backend.run(circuit, shots=shots)

    result = job.result()
 
    print(f"\nResults from IonQ {backend_name} ({shots} shots):")
    print("=" * 50)
    for state, count in result.get_counts().items():
        prob = count / shots
        print(f"|{state}⟩: {prob:.4f} ({count} counts)")
    
    return result
