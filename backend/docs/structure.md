# Backend Structure

```
backend/
├── app.py                    # FastAPI app with CRUD endpoints and /execute_shake
├── main.py                   # MVP API with /make_request, /fetch_results, /fetch_run_history
├── quantum.py                # Executes circuits on quantum computers and saves results
├── circuit_shake.py          # Standalone FastAPI for execute_shake endpoint
├── requirements.txt          # Python dependencies
├── docs/
│   ├── structure.md          # This file - backend file structure
│   └── usage.md              # Usage guide for files and functions
└── utils/
    ├── create_circuit.py     # Converts gate data into Qiskit QuantumCircuit objects
    ├── firebase_rw.py        # Firestore read/write operations for circuits and results
    ├── send_ibm.py           # IBM Quantum execution and result visualization
    └── send_ionq.py          # IonQ execution and result visualization
```
