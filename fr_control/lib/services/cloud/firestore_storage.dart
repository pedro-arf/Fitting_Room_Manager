import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:fr_control/services/cloud/firestore_storage_exceptions.dart';

const tagStatus = 'Status';
const tagPrice = 'Price';
const tagDescription = 'Description';
const tagSize = 'Size';
const tagUrl = 'Image URL';

@immutable
class FirestoreTag {
  final String tagId;
  final String status;
  final double price;
  final String description;
  final String size;
  final String imgUrl;

  const FirestoreTag(
    this.status,
    this.price,
    this.description,
    this.size,
    this.imgUrl, {
    required this.tagId,
  });

  FirestoreTag.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : tagId = snapshot.id,
        status = snapshot.data()[tagStatus] as String,
        price = snapshot.data()[tagPrice] as double,
        description = snapshot.data()[tagDescription] as String,
        size = snapshot.data()[tagSize] as String,
        imgUrl = snapshot.data()[tagUrl] as String;
}

class FirestoreStorage {
  final tags = FirebaseFirestore.instance.collection('tags');

  // Listen for tags in real time
  Stream<Iterable<FirestoreTag>> allTags() => tags
      .snapshots()
      .map((event) => event.docs.map((doc) => FirestoreTag.fromSnapshot(doc)));

  // Get a specific tag once
  Future<Iterable<FirestoreTag>> getTags() async {
    try {
      return await tags.get().then(
            (value) => value.docs.map((doc) => FirestoreTag.fromSnapshot(doc)),
          );
    } catch (e) {
      throw CouldNotGetAllTagsException();
    }
  }

  // Singleton
  static final FirestoreStorage _shared = FirestoreStorage._sharedInstance();
  FirestoreStorage._sharedInstance();
  factory FirestoreStorage() => _shared;
}
