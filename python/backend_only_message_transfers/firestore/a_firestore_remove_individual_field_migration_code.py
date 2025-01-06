from google.cloud import firestore
import time


def remove_fields():
    # Initialize Firestore client
    FIRESTORE_PROJECT_ID = 'university-yearbook'
    db = firestore.Client(project=FIRESTORE_PROJECT_ID)

    # List of fields to remove
    fields_to_remove = [
        'image_two',
        # Add more fields here as needed
        # 'field_name',
        # 'another_field',
    ]

    # List of all university IDs
    university_ids = ['daviduni', 'femiuni', 'funmiuni', 'jamesuni', 'opeuni', 'tomiuni']

    # List of all department collections
    department_collections = [
        'DepartmentalExecutives'
    ]

    batch_size = 500
    stats = {
        'total_processed': 0,
        'fields_removed': {},
        'total_documents': 0
    }

    # Initialize counters for each field
    for field in fields_to_remove:
        stats['fields_removed'][field] = 0

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
                    fields_found = False

                    # Create the field removal dictionary
                    field_updates = {}
                    for field in fields_to_remove:
                        if field in doc_data:
                            # Use FieldValue.DELETE to remove the field
                            field_updates[field] = firestore.DELETE_FIELD
                            stats['fields_removed'][field] += 1
                            fields_found = True

                    # If we found fields to remove
                    if fields_found:
                        doc_ref = dept_ref.document(doc.id)
                        batch.update(doc_ref, field_updates)
                        count += 1
                        stats['total_processed'] += 1

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
        print("\n=== Removal Summary ===")
        print(f"Total documents processed: {stats['total_documents']}")
        print(f"Documents updated: {stats['total_processed']}")
        print("\nFields removed breakdown:")
        for field, count in stats['fields_removed'].items():
            print(f"- {field}: removed from {count} documents")

    except Exception as e:
        print(f"An error occurred: {str(e)}")


if __name__ == "__main__":
    remove_fields()
