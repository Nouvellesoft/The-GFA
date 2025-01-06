from google.cloud import firestore
import time


def batch_update_documents():
    # Initialize Firestore client
    FIRESTORE_PROJECT_ID = 'university-yearbook'
    db = firestore.Client(project=FIRESTORE_PROJECT_ID)

    # Define all new fields you want to add
    new_fields = {
        "image_two": "https://firebasestorage.googleapis.com/v0/b/cov-phoenix-fc.appspot.com/o/Players%2FAI_GENERATED%2Fai_player_2.jpg?alt=media&token=6f10032a-813e-476e-92ee-d34bb35bfff1",
        # Add more fields here as needed, for example:
        # "image_three": "your_url_here",
        # "some_field": "some_value",
        # "another_field": 123,
    }

    # List of all university IDs
    university_ids = ['daviduni', 'femiuni', 'funmiuni', 'jamesuni', 'opeuni', 'tomiuni']

    # List of all department collections
    department_collections = [
        'DepartmentGraduatesA',
        'DepartmentGraduatesB',
        'DepartmentGraduatesC',
        'DepartmentGraduatesD',
        'DepartmentalStaff'
    ]

    batch_size = 500
    stats = {
        'total_updated': 0,
        'fields_added': {},
        'total_documents': 0
    }

    # Initialize counters for each field
    for field in new_fields:
        stats['fields_added'][field] = 0

    try:
        for uni_id in university_ids:
            print(f"\nProcessing university: {uni_id}")

            for dept in department_collections:
                print(f"Processing department: {dept}")

                # Get reference to the department collection
                dept_ref = db.collection('universities').document(uni_id).collection(dept)

                # Stream all documents in the department
                student_docs = dept_ref.stream()

                # Create a new batch
                batch = db.batch()
                count = 0

                for doc in student_docs:
                    stats['total_documents'] += 1
                    doc_data = doc.to_dict()
                    fields_to_update = {}

                    # Check each field individually
                    for field_name, field_value in new_fields.items():
                        if field_name not in doc_data:
                            fields_to_update[field_name] = field_value
                            stats['fields_added'][field_name] += 1

                    # If there are fields to update for this document
                    if fields_to_update:
                        doc_ref = dept_ref.document(doc.id)
                        batch.update(doc_ref, fields_to_update)
                        count += 1
                        stats['total_updated'] += 1

                        # If batch is full, commit and create new batch
                        if count >= batch_size:
                            batch.commit()
                            print(f"Committed batch of {count} documents in {dept}")
                            batch = db.batch()
                            count = 0
                            # Small delay to avoid hitting quota limits
                            time.sleep(1)

                # Commit any remaining documents in the final batch
                if count > 0:
                    batch.commit()
                    print(f"Committed final batch of {count} documents in {dept}")

        # Print detailed statistics
        print("\n=== Update Summary ===")
        print(f"Total documents processed: {stats['total_documents']}")
        print(f"Documents updated: {stats['total_updated']}")
        print("\nFields added breakdown:")
        for field, count in stats['fields_added'].items():
            print(f"- {field}: {count} times")

    except Exception as e:
        print(f"An error occurred: {str(e)}")


if __name__ == "__main__":
    batch_update_documents()
