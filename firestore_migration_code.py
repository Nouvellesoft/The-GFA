from google.cloud import firestore


def migrate_collection(old_client, new_client, old_collection_name, new_collection_root):
    old_collection = old_client.collection(old_collection_name)
    docs = old_collection.stream()

    for doc in docs:
        doc_data = doc.to_dict()
        club_id = doc_data.get('clubId', 'coventryphoenixfc')  # Ensure there's a default clubId

        # Define the new document path
        new_doc_ref = new_client.collection(new_collection_root).document(club_id).collection(
            old_collection_name).document(doc.id)

        # Write data to the new collection
        new_doc_ref.set(doc_data)

    print(f'Migration of {old_collection_name} complete!')


def migrate_data():
    # Initialize Firestore clients
    old_client = firestore.Client(project='cov-phoenix-fc')
    new_client = firestore.Client(project='the-gfa')

    # Discover all collections
    collections = old_client.collections()

    # Migrate each collection
    for collection in collections:
        collection_name = collection.id
        migrate_collection(old_client, new_client, collection_name, 'clubs')

    print('All migrations complete!')

    # Or, Define your collections to migrate
    # collections_to_migrate = [
    #     'FirstTeamClassPlayers',
    #     'SecondTeamClassPlayers',
    #     'Coaches'
    #     'k'
    # ]

    # # Migrate each collection
    # for collection_name in collections_to_migrate:
    #     migrate_collection(old_client, new_client, collection_name, 'clubs')

    # print('All migrations complete!')]


if __name__ == '__main__':
    migrate_data()
