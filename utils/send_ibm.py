import os
from dotenv import load_dotenv
from qiskit import QuantumCircuit, transpile
from qiskit_ibm_runtime import QiskitRuntimeService, SamplerV2 as Sampler, Session, EstimatorV2 as Estimator
from qiskit_ibm_runtime.accounts.exceptions import AccountAlreadyExistsError
import matplotlib.pyplot as plt

load_dotenv()

def send_to_ibm(circuit: QuantumCircuit, shots: int = 1000, backend_name: str = "ibmq_qasm_simulator"):
    """
    Send a quantum circuit to IBM Quantum for execution.
    
    Args:
        circuit: Qiskit QuantumCircuit object
        shots: Number of shots to run (default: 1000)
        backend_name: IBM backend name (default: "ibmq_qasm_simulator")
    
    Returns:
        Job result from IBM
    """

        # Save your credentials (one-time setup)
    try:
        api_token = os.getenv("IBM_API_TOKEN")
        if not api_token:
            raise Exception("IBM_API_TOKEN environment variable not set. Please set it in your .env file.")
        
        QiskitRuntimeService.save_account(channel="ibm_quantum_platform", token=api_token)
        print("Account saved successfully!")
        
    except AccountAlreadyExistsError as e:
        print("Account already exists. Skipping save.")
        pass
    except Exception as e:
        print(f"Error: {e}")

    # Connect to IBM Quantum
    service = QiskitRuntimeService(channel="ibm_quantum_platform")

    # Get a backend
    backend = service.least_busy(operational=True, simulator=False)
    print(f"\nUsing backend: {backend.name}")

    # IMPORTANT: Transpile the circuit for the target backend
    transpiled_qc = transpile(circuit, backend=backend, optimization_level=3)
    print(f"\nTranspiled circuit (optimized for {backend.name}):")

    sampler = Sampler(backend)
    job = sampler.run([transpiled_qc])
    print(f"\nJob submitted! Job ID: {job.job_id()}")

    # Wait for results
    print("Waiting for results...")
    result = job.result()
    print(f"\nResults: {result}")

    return result


def get_ibm_results(circuit: QuantumCircuit, shots: int = 1000, backend_name: str = "ibmq_qasm_simulator", create_plot: bool = True, save_plot: str = None):
    """
    Get IBM Quantum execution results and visualize them.
    """
    try:
        result = send_to_ibm(circuit, shots, backend_name)
        
        # ← CHANGE THIS SECTION - Extract counts properly
        pub_result = result[0]
        data = pub_result.data
        
        # Try to get counts from the correct classical register
        # Check your circuit's classical register name first
        if hasattr(data, 'c'):
            counts = data.c.get_counts()
        elif hasattr(data, 'meas'):
            counts = data.meas.get_counts()
        else:
            # Fallback: find the first valid measurement data
            for attr_name in dir(data):
                if not attr_name.startswith('_'):
                    attr = getattr(data, attr_name)
                    if hasattr(attr, 'get_counts'):
                        counts = attr.get_counts()
                        print(f"Using classical register: {attr_name}")
                        break
        
        print(f"\nResults from IBM {backend_name} ({shots} shots):")
        print("=" * 50)
        for state, count in counts.items():
            prob = count / shots
            print(f"|{state}⟩: {prob:.4f} ({count} counts)")
        
        if create_plot:
            print("\nCreating histogram visualization...")
            create_histogram(counts, shots, 
                           title=f"IBM {backend_name} Results", 
                           save_path=save_plot)
        
        return result
    
    except Exception as e:
        print(f"Error sending circuit to IBM Quantum: {e}")
        import traceback
        traceback.print_exc()  # ← ADD this for better error debugging
        return None


def create_histogram(counts, shots, title="Quantum Measurement Results", save_path=None):
    """Same as your IonQ version — reused for IBM results."""
    states = list(counts.keys())
    counts_list = list(counts.values())
    probabilities = [count / shots for count in counts_list]
    
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 8))
    
    bars1 = ax1.bar(states, counts_list, color='skyblue', alpha=0.7, edgecolor='navy')
    ax1.set_xlabel('Quantum States')
    ax1.set_ylabel('Counts')
    ax1.set_title(f'{title} - Counts (Total Shots: {shots})')
    ax1.grid(True, alpha=0.3)
    
    for bar, count in zip(bars1, counts_list):
        height = bar.get_height()
        ax1.text(bar.get_x() + bar.get_width()/2., height + shots*0.01,
                f'{count}', ha='center', va='bottom', fontweight='bold')
    
    bars2 = ax2.bar(states, probabilities, color='lightcoral', alpha=0.7, edgecolor='darkred')
    ax2.set_xlabel('Quantum States')
    ax2.set_ylabel('Probability')
    ax2.set_title(f'{title} - Probabilities')
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(0, max(probabilities) * 1.1)
    
    for bar, prob in zip(bars2, probabilities):
        height = bar.get_height()
        ax2.text(bar.get_x() + bar.get_width()/2., height + max(probabilities)*0.01,
                f'{prob:.3f}', ha='center', va='bottom', fontweight='bold')
    
    for ax in [ax1, ax2]:
        ax.tick_params(axis='x', rotation=45)
    
    plt.tight_layout()
    
    if save_path:
        plt.savefig(save_path, dpi=300, bbox_inches='tight')
        print(f"Histogram saved to: {save_path}")
    
    plt.show()
    return fig

def print_circuit_info(circuit: QuantumCircuit):
    print(f"Circuit Information:")
    print(f"  Number of qubits: {circuit.num_qubits}")
    print(f"  Number of classical bits: {circuit.num_clbits}")
    print(f"  Circuit depth: {circuit.depth()}")
    print(f"  Number of gates: {len(circuit.data)}")
    print(f"  Circuit:")
    print(circuit.draw(output='text'))
    print()
