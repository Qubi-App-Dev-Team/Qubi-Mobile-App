import firebase_admin
from firebase_admin import credentials, firestore
import json

# Run this script to get the most recent version of your chapter from Firestore

service_account_path = "qubi-app-dev-b8c106a6beb3.json"
collection_name = "chapters"
document_id = "" # Replace this with the document id for the chapter that you want to edit/load into the json file (see in Firebase)

output_path = "chapter.json"

cred = credentials.Certificate(service_account_path)
firebase_admin.initialize_app(cred)

db = firestore.Client.from_service_account_json(service_account_path)

doc_ref = db.collection(collection_name).document(document_id)

doc = doc_ref.get()

if doc.exists:
    data = doc.to_dict()

    print('Found the chapter!')

    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=4, ensure_ascii=False)
else:
    print('Chapter does not exist!')