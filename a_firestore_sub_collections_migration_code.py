from google.cloud import firestore


def migrate_subcollections(client, old_club_id, new_club_id):
    old_club_doc = client.collection('clubs').document(old_club_id)
    sub_collections = old_club_doc.collections()

    for sub_collection in sub_collections:
        sub_collection_name = sub_collection.id
        docs = sub_collection.stream()
        for doc in docs:
            doc_data = doc.to_dict()
            new_doc_ref = client.collection('clubs').document(new_club_id).collection(
                sub_collection_name).document(doc.id)
            new_doc_ref.set(doc_data)
            print(
                f'Added document {doc.id} to subcollection '
                f'{sub_collection_name} in club {new_club_id}')

    print(f'Migration of subcollections from club {old_club_id} to {new_club_id} complete!')


def create_club_document(client, club_id):
    club_ref = client.collection('clubs').document(club_id)
    club_ref.set({
        'name': club_id,  # You can add more initial data as required
    })
    print(f'Created new club document: {club_id}')


def migrate_data():
    # Initialize Firestore client
    client = firestore.Client(project='the-gfa')

    # Specify the old and new club IDs
    old_club_id = 'coventryphoenixfc'  # Existing club ID to migrate data from
    new_club_id = 'josephfc'  # New club ID to migrate data to

    print(f'Creating new club document: {new_club_id}')
    create_club_document(client, new_club_id)

    print(f'Starting migration of subcollections from {old_club_id} to {new_club_id}')
    migrate_subcollections(client, old_club_id, new_club_id)

    print('All operations complete!')


if __name__ == '__main__':
    migrate_data()
