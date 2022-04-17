/// Storage repository class that links to the Firebase Storage service for storing and fetching uploaded files

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;


class Storage {
  final firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;

  /// uploads a file with via its path and names it within the storage
  Future<void> uploadFile(String path, String name) async {
    File file = File(path);
    await storage.ref(name).putFile(file);
  }

  /// gets the download url of a stored file via its name within the storage
  Future<String> downloadURL(String name) async {
    String url = await storage.ref(name).getDownloadURL();
    return url;
  }
}