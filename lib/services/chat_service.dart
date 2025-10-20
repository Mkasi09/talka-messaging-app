import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Send message
  Future<void> sendMessage(String chatId, String message, String type) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
          'message': message,
          'type': type,
          'senderId': _auth.currentUser!.uid,
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        });
  }

  // Get messages stream
  Stream<QuerySnapshot> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Create or get chat
  Future<String> createChat(String user1, String user2) async {
    String chatId = _generateChatId(user1, user2);

    await _firestore.collection('chats').doc(chatId).set({
      'participants': [user1, user2],
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    return chatId;
  }

  String _generateChatId(String user1, String user2) {
    List<String> users = [user1, user2]..sort();
    return '${users[0]}_${users[1]}';
  }

  // Set message reminder
  Future<void> setMessageReminder(String messageId, Duration duration) async {
    // Implementation for reminders using flutter_local_notifications
  }

  // Smart replies
  List<String> getSmartReplies(String message) {
    message = message.toLowerCase();
    if (message.contains('ok') || message.contains('sure')) {
      return ['Great! 👍', 'Okay! 👌', 'Perfect! 😊'];
    } else if (message.contains('thank')) {
      return ['You\'re welcome! 😊', 'Anytime! 👍', 'No problem! 👌'];
    } else if (message.contains('meet') || message.contains('where')) {
      return ['On my way! 🚗', 'Be there soon! ⏱️', 'Running late! 🏃'];
    }
    return ['Okay', 'Sure', 'Got it'];
  }
}
