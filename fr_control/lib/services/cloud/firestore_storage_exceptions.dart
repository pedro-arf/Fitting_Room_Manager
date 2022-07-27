class FirestoreStorageException implements Exception {
  const FirestoreStorageException();
}

class CouldNotGetAllTagsException extends FirestoreStorageException {}
