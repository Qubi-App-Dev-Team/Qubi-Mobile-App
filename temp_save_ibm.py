import os
from dotenv import load_dotenv
from qiskit_ibm_runtime import QiskitRuntimeService
from qiskit_ibm_runtime.accounts.exceptions import AccountAlreadyExistsError

load_dotenv()

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
    
from qiskit import QuantumCircuit, transpile
from qiskit_ibm_runtime import QiskitRuntimeService, SamplerV2 as Sampler

# Connect to IBM Quantum
service = QiskitRuntimeService(channel="ibm_quantum_platform")

# Create a simple quantum circuit
qc = QuantumCircuit(2, 2)
qc.h(0)
qc.cx(0, 1)
qc.measure([0, 1], [0, 1])

print("Original circuit:")
print(qc)

# Get a backend
backend = service.least_busy(operational=True, simulator=False)
print(f"\nUsing backend: {backend.name}")

# IMPORTANT: Transpile the circuit for the target backend
transpiled_qc = transpile(qc, backend=backend, optimization_level=3)
print(f"\nTranspiled circuit (optimized for {backend.name}):")
print(transpiled_qc)

# Run the job with the transpiled circuit
sampler = Sampler(backend)
job = sampler.run([transpiled_qc])
print(f"\nJob submitted! Job ID: {job.job_id()}")

# Wait for results
print("Waiting for results...")
result = job.result()
print("\nResults:")
print(result)