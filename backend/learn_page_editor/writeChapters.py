import firebase_admin
from firebase_admin import credentials, firestore
import json

#Run this script to overwrite your json file content in the chapter you want to edit

service_account_path = "qubi-app-dev-b8c106a6beb3.json"
collection_name = "chapters"
document_id = ""  # Replace this with the document id for the chapter that you want to overwrite with your version (see in Firebase)
# Should be the same value as readChapters.py

output_path = "chapter.json"

cred = credentials.Certificate(service_account_path)
firebase_admin.initialize_app(cred)

db = firestore.Client.from_service_account_json(service_account_path)

doc_ref = db.collection(collection_name).document(document_id)

with open(output_path, "r", encoding="utf-8") as f:
     new_data = json.load(f)

doc_ref.set(new_data, merge = False)

