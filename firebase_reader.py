import os
import json
from dotenv import load_dotenv

import firebase_admin
from firebase_admin import credentials, firestore

load_dotenv()
cred_dict = json.loads(os.getenv('FIREBASE_CREDENTIALS'))

cred = credentials.Certificate(cred_dict)
firebase_admin.initialize_app(cred)

db = firestore.client()

def get_circuit():
    circuits = db.collection('circuits').stream()

    for circuit in circuits:
        gates = circuit.to_dict()['gates']
        num_qubits = circuit.to_dict()['num_qubits']
        num_clbits = circuit.to_dict()['num_clbits']

        return (gates, num_qubits, num_clbits)