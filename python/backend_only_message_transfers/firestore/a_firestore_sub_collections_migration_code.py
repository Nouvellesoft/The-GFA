from google.cloud import firestore

# Initialize Firestore client with the project ID
client = firestore.Client(project='the-gfa')


def move_subcollection(subcollection_name, source_base_path, target_base_path):
    """
    Moves a specific subcollection from a source path to a target path in Firestore.
    Does not delete source documents.
    """
    # Define full source and target paths
    source_path = f'{source_base_path}/{subcollection_name}'
    target_path = f'{target_base_path}/{subcollection_name}'

    try:
        # Get documents from the source subcollection
        source_collection = client.collection(source_path)
        docs = source_collection.stream()

        # Batch write to move documents
        batch = client.batch()
        for doc in docs:
            target_doc_ref = client.collection(target_path).document(doc.id)
            batch.set(target_doc_ref, doc.to_dict())

        batch.commit()
        print(f'Successfully moved documents from {source_path} to {target_path}')

    except Exception as e:
        print(f"An error occurred while migrating {subcollection_name}: {e}")


def migrate_multiple_subcollections():
    """
    Migrates multiple subcollections from one club to another without deleting the source data.
    """
    source_base_path = 'clubs/patriciafc'
    target_base_path = 'clubs/josephfc'

    subcollections = ['MatchDayBannerForClub', 'MatchDayBannerForClubOpp',
                      'PastMatches', 'UpcomingMatches']
    # Add more subcollections here

    for subcollection in subcollections:
        move_subcollection(subcollection, source_base_path, target_base_path)


# Call the function to execute the migration for multiple subcollections
migrate_multiple_subcollections()
