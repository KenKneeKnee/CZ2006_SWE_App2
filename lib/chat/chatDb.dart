import 'package:cloud_firestore/cloud_firestore.dart';

/// Persistent data surrounding chat messages
class DatabaseService {
  // Collection reference
  final CollectionReference EventCollection =
      FirebaseFirestore.instance.collection('events');

  // send message
  sendMessage(String eventId, chatMessageData) {
    FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('messages')
        .add(chatMessageData);
  }

  // get chats of a particular group
  getChats(String eventId) async {
    return FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('messages')
        .orderBy('time')
        .snapshots();
  }
}
