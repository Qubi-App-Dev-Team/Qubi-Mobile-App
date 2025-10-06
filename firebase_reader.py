import os
import json
from dotenv import load_dotenv

import firebase_admin
from firebase_admin import credentials, firestore

from qiskit import QuantumCircuit


load_dotenv()

# Option 1: Use environment variable (requires FIREBASE_CREDENTIALS to be set)
# cred_dict = json.loads(os.getenv('FIREBASE_CREDENTIALS'))
# cred = credentials.Certificate(cred_dict)

# Option 2: Use service account key file (recommended)
cred = credentials.Certificate('service-account-key.json')
firebase_admin.initialize_app(cred)

db = firestore.client()

def get_circuit():
    circuits = db.collection('circuits').stream()

    for circuit in circuits:
        gates = circuit.to_dict()['gates']
        num_qubits = circuit.to_dict()['num_qubits']
        num_clbits = circuit.to_dict()['num_clbits']

        return (gates, num_qubits, num_clbits)

def make_circuit(gates, num_qubits, num_clbits):
    qc = QuantumCircuit(num_qubits, num_clbits)
    for gate in gates:

        if gate['name'] == "h":
            qc.h(*gate['qubits'])
        elif gate['name'] == "x":
            qc.x(*gate['qubits'])
        elif gate['name'] == "cx":
            qc.cx(*gate['qubits'])
        elif gate['name'] == "rz":
            qc.rz(gate['params'][0], *gate['qubits'])
        elif gate['name'] == "measure":
            qc.measure(gate['qubits'], gate['clbits'])
        
    return qc