# Qubi-Mobile-App

***Backend Updates***
*Structure*
- Functions for posting, reading, updating and deleting both runs and circuits exist - FastAPI
- Posting requires the data necessary for a Run and Circuit as classes, the rest require the ID string, not everything
- Connected to firebase database with 2 main collections, 'circuits' and 'runs'
- Circuits store all created circuits, with each document having the circuit itself, name, and number of both qubits and classical bits
- Each run document has a key corresponding to the circuits ID, along with the depth, per shot, quantum computer name, results of run, time intervals and histogram data

*Frontend Connection Process*
- Create circuit
- Frontend sends/save circuit with all values to backend
- Attach document ID of that saved circuit and send alongwith results of run to backend