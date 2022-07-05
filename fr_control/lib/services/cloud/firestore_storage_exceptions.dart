class FirestoreStorageException implements Exception {
  const FirestoreStorageException();
}

class CouldNotGetAllTagsException extends FirestoreStorageException {}

class CouldNotDeleteTagException extends FirestoreStorageException {}
