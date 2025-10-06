import os
from dotenv import load_dotenv
from qiskit import QuantumCircuit
from qiskit_ionq import IonQProvider
import matplotlib.pyplot as plt

load_dotenv()

def send_to_ionq(circuit: QuantumCircuit, shots: int = 1000, backend_name: str = "ionq_simulator"):
    """
    Send a quantum circuit to IonQ for execution.
    
    Args:
        circuit: Qiskit QuantumCircuit object
        shots: Number of shots to run (default: 1000)
        backend_name: IonQ backend to use (default: "ionq_simulator")
                     Options: "ionq_simulator", "ionq_qpu"
    
    Returns:
        Job result from IonQ
    """
    # Get IonQ API token from environment variable
    api_token = os.getenv('IONQ_API_TOKEN')
    if not api_token:
        raise ValueError("IONQ_API_TOKEN environment variable not set. Please set it in your .env file.")
    
    # Initialize IonQ provider
    provider = IonQProvider(token=api_token)
    
    # Get the specified backend
    backend = provider.get_backend(backend_name)
    
    # Submit job directly to the backend
    job = backend.run(circuit, shots=shots)
    
    print(f"Job submitted to IonQ {backend_name}")
    print(f"Job ID: {job.job_id()}")
    
    # Wait for job to complete and get results
    result = job.result()
    
    return result

def get_ionq_results(circuit: QuantumCircuit, shots: int = 1000, backend_name: str = "ionq_simulator", create_plot: bool = True, save_plot: str = None):
    """
    Get IonQ execution results and print them in a readable format.
    
    Args:
        circuit: Qiskit QuantumCircuit object
        shots: Number of shots to run
        backend_name: IonQ backend to use
        create_plot: Whether to create a histogram visualization
        save_plot: Optional path to save the histogram (e.g., "histogram.png")
    """
    try:
        result = send_to_ionq(circuit, shots, backend_name)
        
        # Get the counts from the result
        counts = result.get_counts()
        
        print(f"\nResults from IonQ {backend_name} ({shots} shots):")
        print("=" * 50)
        
        # Print results in binary format
        for state, count in counts.items():
            probability = count / shots
            print(f"|{state}⟩: {probability:.4f} ({count} counts)")
        
        # Create histogram if requested
        if create_plot:
            print(f"\nCreating histogram visualization...")
            create_histogram(counts, shots, 
                           title=f"IonQ {backend_name} Results", 
                           save_path=save_plot)
        
        return result
        
    except Exception as e:
        print(f"Error sending circuit to IonQ: {e}")
        return None

def create_histogram(counts, shots, title="Quantum Measurement Results", save_path=None):
    """
    Create a histogram visualization of quantum measurement results.
    
    Args:
        counts: Dictionary of measurement counts from IonQ result
        shots: Total number of shots
        title: Title for the histogram
        save_path: Optional path to save the plot (e.g., "histogram.png")
    
    Returns:
        matplotlib figure object
    """
    # Convert hex states to binary for better readability
    binary_states = {}
    for hex_state, count in counts.items():
        int_state = int(hex_state, 16)
        # Determine number of qubits from the largest state
        max_state = max(int(hex_state, 16) for hex_state in counts.keys())
        num_qubits = max_state.bit_length() if max_state > 0 else 1
        binary_state = format(int_state, f'0{num_qubits}b')
        binary_states[binary_state] = count
    
    # Prepare data for plotting
    states = list(binary_states.keys())
    counts_list = list(binary_states.values())
    probabilities = [count / shots for count in counts_list]
    
    # Create the histogram
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 8))
    
    # Bar chart for counts
    bars1 = ax1.bar(states, counts_list, color='skyblue', alpha=0.7, edgecolor='navy')
    ax1.set_xlabel('Quantum States')
    ax1.set_ylabel('Counts')
    ax1.set_title(f'{title} - Counts (Total Shots: {shots})')
    ax1.grid(True, alpha=0.3)
    
    # Add count labels on bars
    for bar, count in zip(bars1, counts_list):
        height = bar.get_height()
        ax1.text(bar.get_x() + bar.get_width()/2., height + shots*0.01,
                f'{count}', ha='center', va='bottom', fontweight='bold')
    
    # Bar chart for probabilities
    bars2 = ax2.bar(states, probabilities, color='lightcoral', alpha=0.7, edgecolor='darkred')
    ax2.set_xlabel('Quantum States')
    ax2.set_ylabel('Probability')
    ax2.set_title(f'{title} - Probabilities')
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(0, max(probabilities) * 1.1)
    
    # Add probability labels on bars
    for bar, prob in zip(bars2, probabilities):
        height = bar.get_height()
        ax2.text(bar.get_x() + bar.get_width()/2., height + max(probabilities)*0.01,
                f'{prob:.3f}', ha='center', va='bottom', fontweight='bold')
    
    # Rotate x-axis labels for better readability
    for ax in [ax1, ax2]:
        ax.tick_params(axis='x', rotation=45)
    
    plt.tight_layout()
    
    # Save if path provided
    if save_path:
        plt.savefig(save_path, dpi=300, bbox_inches='tight')
        print(f"Histogram saved to: {save_path}")
    
    plt.show()
    
    return fig

def print_circuit_info(circuit: QuantumCircuit):
    """Print information about the circuit before sending to IonQ."""
    print(f"Circuit Information:")
    print(f"  Number of qubits: {circuit.num_qubits}")
    print(f"  Number of classical bits: {circuit.num_clbits}")
    print(f"  Circuit depth: {circuit.depth()}")
    print(f"  Number of gates: {len(circuit.data)}")
    print(f"  Circuit:")
    print(circuit.draw(output='text'))
    print()

