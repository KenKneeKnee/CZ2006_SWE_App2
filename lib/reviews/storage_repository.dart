import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;


class Storage {
  final firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;

  Future<void> uploadFile(String path, String name) async {
    File file = File(path);
    await storage.ref(name).putFile(file);
  }

  Future<String> downloadURL(String imageName) async {
    String url = await storage.ref(imageName).getDownloadURL();
    return url;
  }
}