# Backend Usage Guide

## API Files

### [app.py](../app.py)

**Purpose**: Original FastAPI application with full CRUD operations for circuits and runs.

**Endpoints**:
- `POST /run` - Create a new run record with circuit results
- `POST /circuit` - Create a new circuit with auto-generated ID
- `POST /circuit/{hash_id}` - Create circuit with specific hash ID
- `GET /runs/{identifier}` - Retrieve a run by ID
- `GET /circuits/{identifier}` - Retrieve a circuit by ID
- `PUT /runs/{identifier}/{field}/{value}` - Update a run field
- `PUT /circuits/{identifier}/{field}/{value}` - Update a circuit field
- `DELETE /runs/{identifier}` - Delete a run
- `DELETE /circuits/{identifier}` - Delete a circuit
- `POST /execute_shake` - Hash circuit, save if new, execute on quantum computer

**Key Functions**:
- `circuit_exists(hash_id: str) -> bool` - Check if circuit exists in Firestore
- `canonicalize_and_hash(circuit: dict) -> str` - Generate SHA-256 hash from circuit dict

**Models**:
- `ExecuteShakeRequest` - user_id, circuit, quantum_computer, circuit_name
- `Time` - total, execution, pending
- `Model` - first, second, third, fourth (histogram values)
- `Gate` - name, qubit
- `Measurement` - name, qubit, classical
- `Run` - circuit_id, depth, result, time, per_shot, quantum_computer, histogram
- `Circuit` - gates, classical, qubit, measure

---

### [main.py](../main.py)

**Purpose**: Current MVP API focused on request/response workflow.

**Endpoints**:
- `POST /make_request` - Submit quantum circuit execution request
  - Creates circuit if doesn't exist
  - Creates run_request document
  - Queues background task to execute circuit
  - Returns run_request_id

- `GET /fetch_results?run_request_id={id}` - Check execution status
  - Returns completed results if available (status 200)
  - Returns "waiting" status if pending (status 202)
  - Returns not found if request doesn't exist (status 404)

- `GET /fetch_run_history?user_id={id}&limit={n}` - Get user's run history
  - Fetches completed runs from run_results collection
  - Ordered by created_at descending
  - Default limit: 20

**Key Functions**:
- `serialize_firestore_data(data)` - Convert Firestore timestamps to ISO strings
- `serialize_value(value)` - Recursively serialize nested Firestore objects
- `canonicalize_and_hash(circuit: dict) -> str` - Generate deterministic SHA-256 hash
- `circuit_exists(circuit_id: str) -> bool` - Check if circuit exists in Firestore
- `insert_circuit(circuit_dict: dict) -> str` - Insert circuit if new, return circuit_id

**Models**:
- `MakeRequestDTO` - user_id, shots, circuit, quantum_computer

---

### [circuit_shake.py](../circuit_shake.py)

**Purpose**: Standalone FastAPI service for execute_shake endpoint (alternative to app.py version).

**Endpoints**:
- `POST /execute_shake` - Hash circuit, check existence, post if new, execute

**Key Functions**:
- `canonicalize_and_hash(circuit: dict) -> str` - Generate SHA-256 hash from circuit

**Models**:
- `ExecuteShakeRequest` - circuit, quantum_computer, circuit_name

---

## Quantum Processing

### [quantum.py](../quantum.py)

**Purpose**: Core module for executing quantum circuits on quantum computers.

**Functions**:

#### `send_circuit_old(circuit_id, quantum_computer_name)`
Legacy function for circuit execution.
- **Parameters**: circuit_id (str), quantum_computer_name (str)
- **Returns**: tuple (run_id, elapsed_time, res) or None
- **Process**: Fetch circuit → Create QuantumCircuit → Execute on quantum computer → Save results → Return

#### `send_circuit(run_request_id, user_id, circuit_id, circuit, quantum_computer, shots)`
Current function for circuit execution (used by main.py).
- **Parameters**: run_request_id (str), user_id (str), circuit_id (str), circuit (dict), quantum_computer (str), shots (int)
- **Returns**: run_id (str) or None
- **Process**: Fetch circuit → Create QuantumCircuit → Execute → Save to run_results collection
- **Supported Quantum Computers**: 'ionq_simulator', IBM simulators

---

## Utilities

### [utils/create_circuit.py](../utils/create_circuit.py)

**Purpose**: Convert gate data into Qiskit QuantumCircuit objects.

**Functions**:

#### `create_circuit(gates, num_qubits, num_clbits)`
- **Parameters**: gates (list), num_qubits (int), num_clbits (int)
- **Returns**: QuantumCircuit object
- **Supported Gates**:
  - Single-qubit: h, x, y, z, t, tdg
  - Two-qubit: cx, cz
  - Parameterized: rz (requires params)
  - Measurement: measure (requires qubits and clbits)

**Example**:
```python
gates = [
    {"name": "h", "qubits": [0]},
    {"name": "cx", "qubits": [0, 1]},
    {"name": "measure", "qubits": [0, 1], "clbits": [0, 1]}
]
qc = create_circuit(gates, num_qubits=2, num_clbits=2)
```

---

### [utils/firebase_rw.py](../utils/firebase_rw.py)

**Purpose**: Firestore database operations for circuits and results.

**Functions**:

#### `add_results(run_request_id, user_id, circuit_id, elapsed_time, shots, results)`
Add results to run_results collection using run_request_id as document ID.
- **Parameters**: run_request_id, user_id, circuit_id, elapsed_time, shots, results (Qiskit Result)
- **Returns**: run_request_id
- **Stores**: success, circuit_id, user_id, quantum_computer, histograms, shots, elapsed_time, created_at

#### `get_circuit_by_id(circuit_id)`
Retrieve circuit from Firestore.
- **Parameters**: circuit_id (str)
- **Returns**: tuple (gates, num_qubits, num_clbits) or None if not found

#### `listen_for_circuits(callback)`
Real-time listener for new circuit documents.
- **Parameters**: callback function that takes (doc_id, gates, num_qubits, num_clbits)
- **Usage**: Watches circuits collection and triggers callback on new documents

---

### [utils/send_ibm.py](../utils/send_ibm.py)

**Purpose**: Execute circuits on IBM Quantum and visualize results.

**Functions**:

#### `send_to_ibm(circuit, shots=1000, backend_name="ibmq_qasm_simulator")`
Submit circuit to IBM Quantum.
- **Parameters**: circuit (QuantumCircuit), shots (int), backend_name (str)
- **Returns**: Qiskit Result object
- **Process**: Save IBM API credentials → Connect to IBM Quantum → Transpile circuit → Run on backend → Return results

#### `get_ibm_results(circuit, shots=1000, backend_name="ibmq_qasm_simulator", create_plot=True, save_plot=None)`
Execute circuit and get formatted results.
- **Parameters**: circuit, shots, backend_name, create_plot (bool), save_plot (str path)
- **Returns**: Qiskit Result object or None
- **Output**: Prints counts/probabilities, optionally creates histogram

#### `create_histogram(counts, shots, title="Quantum Measurement Results", save_path=None)`
Generate visualization of quantum measurement results.
- **Parameters**: counts (dict), shots (int), title (str), save_path (str)
- **Returns**: matplotlib figure object
- **Creates**: Two subplots (counts and probabilities)

#### `print_circuit_info(circuit)`
Display circuit information.
- **Parameters**: circuit (QuantumCircuit)
- **Prints**: Number of qubits, classical bits, depth, gates, and circuit diagram

---

### [utils/send_ionq.py](../utils/send_ionq.py)

**Purpose**: Execute circuits on IonQ quantum computers and visualize results.

**Functions**:

#### `send_to_ionq(circuit, shots=1000, backend_name="ionq_simulator")`
Submit circuit to IonQ.
- **Parameters**: circuit (QuantumCircuit), shots (int), backend_name (str)
- **Returns**: Qiskit Result object
- **Backends**: 'ionq_simulator', 'ionq_qpu'
- **Process**: Get API token → Initialize provider → Submit job → Wait for results

#### `get_ionq_results(circuit, shots=1000, backend_name="ionq_simulator", create_plot=True, save_plot=None)`
Execute circuit and get formatted results.
- **Parameters**: circuit, shots, backend_name, create_plot (bool), save_plot (str path)
- **Returns**: Qiskit Result object or None
- **Output**: Prints counts/probabilities, optionally creates histogram

#### `create_histogram(counts, shots, title="Quantum Measurement Results", save_path=None)`
Generate visualization of quantum measurement results.
- **Parameters**: counts (dict), shots (int), title (str), save_path (str)
- **Returns**: matplotlib figure object
- **Features**: Converts hex states to binary, creates counts and probability charts

#### `print_circuit_info(circuit)`
Display circuit information.
- **Parameters**: circuit (QuantumCircuit)
- **Prints**: Number of qubits, classical bits, depth, gates, and circuit diagram

---

## Example Workflows

### 1. Execute Circuit via main.py API

```python
# POST request to /make_request
{
  "user_id": "user_01",
  "shots": 1000,
  "quantum_computer": "ionq_simulator",
  "circuit": {
    "gates": [
      {"name": "h", "qubits": [0]},
      {"name": "cx", "qubits": [0, 1]},
      {"name": "measure", "qubits": [0, 1], "clbits": [0, 1]}
    ],
    "num_qubits": 2,
    "num_clbits": 2
  }
}

# Response: {"run_request_id": "abc123..."}

# Check results
# GET /fetch_results?run_request_id=abc123...
```

### 2. Execute Circuit via app.py

```python
# POST request to /execute_shake
{
  "user_id": "dummy_id",
  "circuit": {
    "gates": [
      {"name": "h", "qubit": [0]},
      {"name": "cx", "qubit": [0, 1]}
    ],
    "classical": 2,
    "qubit": 2,
    "measure": {
      "name": "measure",
      "qubit": [0, 1],
      "classical": [0, 1]
    }
  },
  "quantum_computer": "ionq_simulator",
  "circuit_name": "Test Circuit"
}
```

### 3. Direct Quantum Execution

```python
from quantum import send_circuit
from utils.create_circuit import create_circuit

# Option 1: Using circuit_id (fetches from Firebase)
run_id = send_circuit(
    run_request_id="req_123",
    user_id="user_01",
    circuit_id="circuit_hash",
    circuit={},
    quantum_computer="ionq_simulator",
    shots=1000
)

# Option 2: Create circuit directly
gates = [
    {"name": "h", "qubits": [0]},
    {"name": "measure", "qubits": [0], "clbits": [0]}
]
qc = create_circuit(gates, 1, 1)
```

---

## Environment Variables Required

```bash
# .env file
FIREBASE_CREDENTIALS={"type":"service_account",...}  # Firebase service account JSON
IBM_API_TOKEN=your_ibm_token                         # IBM Quantum API token
IONQ_API_TOKEN=your_ionq_token                       # IonQ API token
```
