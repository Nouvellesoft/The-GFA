from google.cloud import firestore

# Initialize Firestore
db = firestore.Client()


def list_all_club_documents():
    try:
        # Fetch all documents in the 'clubs' collection
        clubs_ref = db.collection('clubs')
        docs = clubs_ref.stream()

        print("Documents in 'clubs' collection:")
        for doc in docs:
            print(f"Document ID: {doc.id}")
            # Print document data
            print(f"Document data: {doc.to_dict()}")

            # Check and list subcollections
            subcollections = doc.reference.collections()
            if subcollections:
                print("Subcollections:")
                for subcollection in subcollections:
                    print(f"Subcollection ID: {subcollection.id}")
                    # List documents in subcollection
                    sub_docs = subcollection.stream()
                    for sub_doc in sub_docs:
                        print(f"  Subcollection Document ID: {sub_doc.id}")
                        print(f"  Subcollection Document data: {sub_doc.to_dict()}")
            else:
                print("No subcollections found.")

    except Exception as e:
        print(f"An error occurred: {e}")


if __name__ == '__main__':
    list_all_club_documents()
