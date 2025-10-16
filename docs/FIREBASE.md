# Firebase Integration Guide

Complete guide to Firebase/Firestore integration for the Qubi Mobile App backend.

## Overview

The Qubi backend uses Firebase Firestore as a real-time database to:
1. Receive quantum circuit submissions from mobile apps
2. Store execution results for mobile app consumption
3. Enable real-time synchronization between mobile and backend

## Firebase Project Setup

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project" or select existing project
3. Enter project name (e.g., "qubi-mobile-app")
4. Enable/disable Google Analytics (optional)
5. Click "Create Project"

### 2. Enable Firestore Database

1. In Firebase Console, navigate to **Build** → **Firestore Database**
2. Click "Create Database"
3. Select mode:
   - **Production mode**: Recommended (secure by default)
   - **Test mode**: Only for development (publicly readable/writable)
4. Choose Firestore location (cannot be changed later)
   - Recommended: Choose closest to your users
   - Example: `us-central1`, `europe-west1`, `asia-southeast1`
5. Click "Enable"

### 3. Create Service Account

The backend uses a service account for admin-level access to Firestore.

**Steps**:
1. Go to **Project Settings** (gear icon) → **Service Accounts**
2. Click "Generate New Private Key"
3. Click "Generate Key" in the confirmation dialog
4. Save the downloaded JSON file as `service-account-key.json`
5. **Important**: Add this file to `.gitignore` to prevent committing secrets

**Alternative**: Set as environment variable:
```bash
export FIREBASE_CREDENTIALS='{"type":"service_account",...}'
```

### 4. Configure Firebase Authentication (Mobile App)

For mobile app integration:

1. Navigate to **Build** → **Authentication**
2. Click "Get Started"
3. Enable sign-in providers:
   - **Email/Password**: Basic authentication
   - **Google**: Social login
   - **Anonymous**: Guest access
4. Manage users in "Users" tab

## Firestore Data Model

### Collections

The backend uses two main collections:

```
firestore/
├── circuits/          # Input: Circuit definitions from mobile app
│   └── {doc_id}       # Auto-generated document ID
└── runs/              # Output: Execution results from backend
    └── {doc_id}       # Auto-generated document ID
```

### Collection: `circuits`

**Purpose**: Stores quantum circuit definitions submitted by mobile users

**Document Structure**:
```typescript
{
  gates: Array<{
    name: string;           // "h", "x", "cx", "rz", "measure"
    qubits: number[];       // Target qubit indices
    clbits?: number[];      // Classical bit indices (measure only)
    params?: number[];      // Gate parameters (rz only)
  }>;
  num_qubits: number;       // Total number of qubits
  num_clbits: number;       // Total number of classical bits
  created_at?: timestamp;   // Optional: Creation timestamp
  user_id?: string;         // Optional: User ID from Firebase Auth
  circuit_name?: string;    // Optional: User-provided name
}
```

**Example Document**:
```json
{
  "gates": [
    {
      "name": "h",
      "qubits": [0]
    },
    {
      "name": "cx",
      "qubits": [0, 1]
    },
    {
      "name": "measure",
      "qubits": [0, 1],
      "clbits": [0, 1]
    }
  ],
  "num_qubits": 2,
  "num_clbits": 2,
  "created_at": "2024-01-15T10:30:00Z",
  "user_id": "abc123",
  "circuit_name": "Bell State"
}
```

**Indexes**: None required for current usage

---

### Collection: `runs`

**Purpose**: Stores quantum execution results for mobile app retrieval

**Document Structure**:
```typescript
{
  circuit_id: string;              // Reference to circuits/{doc_id}
  quantum_computer: string;        // Backend name (e.g., "ionq_simulator")
  histogram: {[state: string]: number}; // Measurement counts (hex format)
  total_runtime: number;           // Execution time in seconds
  created_at?: timestamp;          // Optional: Auto-generated timestamp
}
```

**Example Document**:
```json
{
  "circuit_id": "circuits/xyz789",
  "quantum_computer": "ionq_simulator",
  "histogram": {
    "0x0": 502,
    "0x3": 498
  },
  "total_runtime": 1.23,
  "created_at": "2024-01-15T10:30:05Z"
}
```

**Histogram Format**:
- **Keys**: Hexadecimal string representation of measurement states
  - `"0x0"` = binary `00` = decimal `0`
  - `"0x1"` = binary `01` = decimal `1`
  - `"0x2"` = binary `10` = decimal `2`
  - `"0x3"` = binary `11` = decimal `3`
- **Values**: Count of measurements in that state

**Indexes**:
- Recommended: Create composite index on `(circuit_id, created_at)` for efficient queries

---

## Firestore Security Rules

### Production Rules

Secure rules for production deployment:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper function: User is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }

    // Helper function: User owns the document
    function isOwner(userId) {
      return request.auth.uid == userId;
    }

    // circuits collection
    match /circuits/{circuitId} {
      // Authenticated users can create circuits
      allow create: if isAuthenticated()
                    && request.resource.data.keys().hasAll(['gates', 'num_qubits', 'num_clbits'])
                    && request.resource.data.user_id == request.auth.uid;

      // Users can read their own circuits
      allow read: if isAuthenticated()
                  && resource.data.user_id == request.auth.uid;

      // Users can update their own circuits (before processing)
      allow update: if isAuthenticated()
                    && resource.data.user_id == request.auth.uid;

      // Users can delete their own circuits
      allow delete: if isAuthenticated()
                    && resource.data.user_id == request.auth.uid;
    }

    // runs collection
    match /runs/{runId} {
      // Backend only (via Admin SDK) can create
      allow create: if false;

      // Users can read runs for their circuits
      allow read: if isAuthenticated();

      // No updates or deletes allowed
      allow update, delete: if false;
    }
  }
}
```

### Development Rules (Insecure)

For development/testing only:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true; // WARNING: Public access!
    }
  }
}
```

**⚠️ Never use development rules in production!**

---

## Backend Implementation

### Initialize Firebase Admin SDK

Located in [utils/firebase_rw.py](../utils/firebase_rw.py):

```python
import os
import json
import firebase_admin
from firebase_admin import credentials, firestore
from dotenv import load_dotenv

load_dotenv()

# Option 1: Use environment variable
try:
    cred_dict = json.loads(os.getenv('FIREBASE_CREDENTIALS'))
    cred = credentials.Certificate(cred_dict)
except:
    # Option 2: Use service account key file
    cred = credentials.Certificate('service-account-key.json')

# Initialize Firebase app
firebase_admin.initialize_app(cred)

# Get Firestore client
db = firestore.client()
```

### Listen for New Circuits

Real-time snapshot listener:

```python
def listen_for_circuits(callback):
    """
    Listen for new circuit documents and call callback.

    Args:
        callback: Function(doc_id, gates, num_qubits, num_clbits)
    """
    processed_docs = set()

    def on_snapshot(col_snapshot, changes, read_time):
        for change in changes:
            if change.type.name == 'ADDED':
                doc = change.document
                doc_id = doc.id

                if doc_id not in processed_docs:
                    processed_docs.add(doc_id)

                    data = doc.to_dict()
                    callback(
                        doc_id,
                        data['gates'],
                        data['num_qubits'],
                        data['num_clbits']
                    )

    # Set up listener
    col_ref = db.collection('circuits')
    col_watch = col_ref.on_snapshot(on_snapshot)

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        col_watch.unsubscribe()
```

### Write Results to Firestore

```python
def add_results(doc_id, elapsed_time, results):
    """
    Add execution results to runs collection.

    Args:
        doc_id: Circuit document ID
        elapsed_time: Total runtime in seconds
        results: Qiskit Result object

    Returns:
        str: Generated run document ID
    """
    runs_ref = db.collection('runs')
    new_run = runs_ref.document()  # Auto-generate ID

    data = {
        'circuit_id': doc_id,
        'quantum_computer': results.backend_name,
        'histogram': results.get_counts(),
        'total_runtime': round(elapsed_time, 2)
    }

    new_run.set(data)
    return new_run.id
```

---

## Mobile App Integration

### Setup Firebase in Mobile App

**Flutter Example**:

```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^latest
  cloud_firestore: ^latest
  firebase_auth: ^latest
```

```dart
// main.dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
```

### Submit Circuit to Firestore

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> submitCircuit(List<Map<String, dynamic>> gates,
                           int numQubits, int numClbits) async {
  final user = FirebaseAuth.instance.currentUser;

  await FirebaseFirestore.instance.collection('circuits').add({
    'gates': gates,
    'num_qubits': numQubits,
    'num_clbits': numClbits,
    'user_id': user?.uid,
    'created_at': FieldValue.serverTimestamp(),
  });
}

// Example usage
await submitCircuit([
  {'name': 'h', 'qubits': [0]},
  {'name': 'cx', 'qubits': [0, 1]},
  {'name': 'measure', 'qubits': [0, 1], 'clbits': [0, 1]},
], 2, 2);
```

### Listen for Results

```dart
Stream<List<Map<String, dynamic>>> getResults(String circuitId) {
  return FirebaseFirestore.instance
      .collection('runs')
      .where('circuit_id', isEqualTo: circuitId)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => doc.data())
          .toList());
}

// Example usage
StreamBuilder<List<Map<String, dynamic>>>(
  stream: getResults(circuitId),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final results = snapshot.data!;
      // Display results
      return ResultsWidget(results: results);
    }
    return CircularProgressIndicator();
  },
)
```

---

## Advanced Queries

### Query Runs by Circuit ID

```python
# Python backend
runs = db.collection('runs').where('circuit_id', '==', 'abc123').get()
for run in runs:
    print(f"{run.id}: {run.to_dict()}")
```

```dart
// Flutter mobile app
final runs = await FirebaseFirestore.instance
    .collection('runs')
    .where('circuit_id', isEqualTo: 'abc123')
    .get();
```

### Query Recent Circuits

```python
# Get last 10 circuits
circuits = db.collection('circuits') \
    .order_by('created_at', direction=firestore.Query.DESCENDING) \
    .limit(10) \
    .get()
```

### Query User's Circuits

```dart
final userCircuits = await FirebaseFirestore.instance
    .collection('circuits')
    .where('user_id', isEqualTo: currentUser.uid)
    .orderBy('created_at', descending: true)
    .get();
```

---

## Firestore Best Practices

### 1. Document ID Strategy

**Auto-generated IDs** (Recommended):
```python
# Let Firestore generate unique ID
doc_ref = db.collection('circuits').document()
doc_ref.set(data)
```

**Custom IDs**:
```python
# Use custom ID (must be unique)
db.collection('circuits').document('my-custom-id').set(data)
```

### 2. Timestamps

Always include timestamps for sorting and filtering:

```python
import firestore

data = {
    'gates': [...],
    'created_at': firestore.SERVER_TIMESTAMP  # Server-side timestamp
}
```

### 3. Data Validation

Validate data before writing:

```python
def validate_circuit(gates, num_qubits, num_clbits):
    if not isinstance(gates, list):
        raise ValueError("gates must be a list")
    if num_qubits < 1 or num_clbits < 0:
        raise ValueError("Invalid qubit/clbit count")
    # ... more validation
```

### 4. Error Handling

Always handle Firestore errors:

```python
from google.cloud.exceptions import GoogleCloudError

try:
    doc_ref.set(data)
except GoogleCloudError as e:
    print(f"Firestore error: {e}")
    # Implement retry logic or alert
```

### 5. Batched Writes

For multiple writes, use batched operations:

```python
batch = db.batch()

for circuit in circuits:
    doc_ref = db.collection('circuits').document()
    batch.set(doc_ref, circuit)

batch.commit()  # Atomic operation
```

---

## Monitoring and Debugging

### Firebase Console Usage Dashboard

1. Go to **Firestore Database** → **Usage** tab
2. Monitor:
   - Document reads/writes
   - Storage usage
   - Network egress

### View Real-time Data

1. Navigate to **Firestore Database** → **Data** tab
2. Browse collections and documents
3. Manually add/edit/delete documents for testing

### Firebase Emulator (Local Development)

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Initialize emulators
firebase init emulators

# Start Firestore emulator
firebase emulators:start --only firestore
```

Update backend to use emulator:

```python
import os
os.environ['FIRESTORE_EMULATOR_HOST'] = 'localhost:8080'

# Initialize Firebase as normal
firebase_admin.initialize_app(cred)
db = firestore.client()
```

---

## Troubleshooting

### Common Issues

**1. Permission Denied**
```
PERMISSION_DENIED: Missing or insufficient permissions
```
**Solution**: Check security rules and user authentication

**2. Document Not Found**
```
NotFound: 404 Document not found
```
**Solution**: Verify document ID and collection path

**3. Invalid Credentials**
```
ValueError: Invalid JSON credentials
```
**Solution**: Check `FIREBASE_CREDENTIALS` or service account file

**4. Listener Stops Working**
```
Listener stopped receiving updates
```
**Solution**: Check network connection, Firebase quotas, and error logs

---

## Performance Optimization

### 1. Use Indexes

Create indexes for frequently queried fields:

**Composite Index Example**:
- Collection: `runs`
- Fields: `circuit_id` (Ascending), `created_at` (Descending)

Create in Firebase Console or via CLI:

```bash
firebase firestore:indexes
```

### 2. Limit Data Size

- Keep documents under 1 MB
- Use references instead of embedding large data
- Paginate large result sets

### 3. Minimize Reads

```python
# Bad: Read entire collection
all_docs = db.collection('circuits').get()

# Good: Query with limits
recent_docs = db.collection('circuits').limit(10).get()
```

### 4. Use Offline Persistence (Mobile)

```dart
// Enable offline persistence in Flutter
await FirebaseFirestore.instance.settings = Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

---

## Cost Estimation

### Firestore Pricing (as of 2024)

**Free Tier**:
- 50K document reads/day
- 20K document writes/day
- 20K document deletes/day
- 1 GB storage

**Paid Tier**:
- $0.036 per 100K reads
- $0.108 per 100K writes
- $0.018 per GB storage

**Typical Usage**:
- 100 circuits/day: ~$0.01/month
- 1000 circuits/day: ~$0.10/month

---

## Security Checklist

- [ ] Service account key is in `.gitignore`
- [ ] Security rules restrict access to authenticated users only
- [ ] Users can only read/write their own circuits
- [ ] Backend uses Admin SDK with service account
- [ ] API tokens stored in environment variables
- [ ] Firestore rules tested with Firebase Emulator
- [ ] Production and development projects are separate
- [ ] Regular audit of IAM permissions

---

## Migration and Backup

### Export Firestore Data

```bash
gcloud firestore export gs://your-bucket/backup-folder
```

### Import Firestore Data

```bash
gcloud firestore import gs://your-bucket/backup-folder
```

### Backup Strategy

1. **Automated Daily Backups**: Use Cloud Scheduler + Cloud Functions
2. **Version Control**: Export critical data to version-controlled JSON
3. **Disaster Recovery**: Maintain separate Firebase project for DR

---

## Additional Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [Firestore Security Rules Guide](https://firebase.google.com/docs/firestore/security/get-started)
- [Firebase Admin SDK for Python](https://firebase.google.com/docs/admin/setup)
- [Firestore Data Model Best Practices](https://firebase.google.com/docs/firestore/manage-data/structure-data)
