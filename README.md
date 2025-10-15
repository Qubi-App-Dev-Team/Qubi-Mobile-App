# Qubi-Mobile-App

**Backend Updates**

*Structure*
- Functions for posting, reading, updating and deleting both runs and circuits exist - FastAPI
- Functions for posting, reading, and deleting chapters also exist - FastAPI
- Posting requires the data necessary for a Run, Circuit, and Chapter as classes, the rest require the ID string, not everything
- Connected to firebase database with 3 main collections, 'circuits', 'runs', and 'chapters'
- Circuits store all created circuits, with each document having the circuit itself, name, and number of both qubits and classical bits
- Each run document has a key corresponding to the circuits ID, along with the depth, per shot, quantum computer name, results of run, time intervals and histogram data
- Chapters store information about the chapter and a list of sections
- Sections store information about the section and a list of pages
- Pages store a list of components that will be used to build the page

*Frontend Connection Process*
- Create circuit
- Frontend sends/save circuit with all values to backend
- Attach document ID of that saved circuit and send alongwith results of run to backend
