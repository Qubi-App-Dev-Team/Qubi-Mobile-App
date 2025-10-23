# Qubi Mobile App - Quantum Computing Backend

A Python-based backend service that integrates Firebase with IonQ quantum computers to enable mobile quantum circuit execution.

## Overview

Qubi Mobile App is a real-time quantum computing backend that:
- Listens for quantum circuit submissions via Firebase Firestore
- Executes circuits on IonQ quantum simulators and hardware
- Generates visualization histograms of measurement results
- Stores results back to Firebase for mobile app consumption

**Key Features:**
- Real-time circuit processing with Firebase listeners
- IonQ quantum computer integration (simulator + QPU)
- Automatic histogram generation and storage
- Support for H, X, CX, RZ, and measurement gates
- Seamless mobile app integration via Firestore

## Quick Start

### Prerequisites
- Python 3.8+
- IonQ API token
- Firebase project with Firestore enabled
- Firebase service account credentials

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd Qubi-Mobile-App

# Install dependencies
pip install -r requirements.txt

# Create .env file
cp .env.example .env  # Then edit with your credentials
```

### Configuration

Create a `.env` file in the project root:

```env
IONQ_API_TOKEN=your_ionq_api_token_here
FIREBASE_CREDENTIALS={"type":"service_account",...}
```

Or place your Firebase service account key as `service-account-key.json` in the project root.

### Run the Backend

```bash
python main.py
```

Expected output:
```
Starting Firebase listener for 'circuits' collection...
Waiting for new documents...
```

The service is now listening for circuit submissions from your mobile app!

## Project Structure

```
Qubi-Mobile-App/
├── main.py                 # Main application entry point
├── utils/
│   ├── create_circuit.py   # Quantum circuit construction
│   ├── firebase_rw.py      # Firebase read/write operations
│   ├── send_ionq.py        # IonQ quantum computer integration
│   └── send_ibm.py         # IBM Quantum backend (future)
├── results/                # Generated histogram visualizations
├── docs/                   # Comprehensive documentation
│   ├── QUANTUM_BACKEND.md  # Backend overview and setup (this file)
│   └── FIREBASE.md         # Firebase/Firestore integration guide
├── requirements.txt        # Python dependencies
└── .env                    # Environment configuration (not in git)
```

## How It Works

1. **Mobile app** user creates a quantum circuit using a visual interface
2. Circuit data is submitted to Firebase `circuits` collection
3. **Python backend** listens for new circuit documents
4. Backend constructs Qiskit circuit and submits to IonQ
5. IonQ executes the circuit on quantum hardware/simulator
6. Backend generates histogram visualization
7. Results are stored in Firebase `runs` collection
8. **Mobile app** retrieves and displays results to user

## Example Circuit Submission

Submit this JSON to the `circuits` collection in Firebase:

```json
{
  "gates": [
    {"name": "h", "qubits": [0]},
    {"name": "cx", "qubits": [0, 1]},
    {"name": "measure", "qubits": [0, 1], "clbits": [0, 1]}
  ],
  "num_qubits": 2,
  "num_clbits": 2
}
```

The backend will process it and create a result document in the `runs` collection:

```json
{
  "circuit_id": "abc123",
  "quantum_computer": "ionq_simulator",
  "histogram": {
    "0x0": 502,
    "0x3": 498
  },
  "total_runtime": 1.23
}
```

## Supported Quantum Gates

| Gate | Description | Example |
|------|-------------|---------|
| H | Hadamard (superposition) | `{"name": "h", "qubits": [0]}` |
| X | Pauli-X (bit flip) | `{"name": "x", "qubits": [1]}` |
| CX | CNOT (entanglement) | `{"name": "cx", "qubits": [0, 1]}` |
| RZ | Z-rotation | `{"name": "rz", "qubits": [0], "params": [1.57]}` |
| Measure | Measurement | `{"name": "measure", "qubits": [0], "clbits": [0]}` |

## Documentation

Comprehensive documentation is available in the [`docs/`](../docs/) folder:

- **[QUANTUM_BACKEND.md](QUANTUM_BACKEND.md)** (this file) - Backend overview, setup, and quick start guide
- **[FIREBASE.md](FIREBASE.md)** - Complete Firebase/Firestore integration guide with security rules, data models, and mobile app integration examples