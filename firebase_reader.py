from dotenv import load_dotenv

import json
import os

import firebase_admin
from firebase_admin import credentials, firestore

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