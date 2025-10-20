import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:talka/screens/chat_detail_screen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _getChatId(String phone1, String phone2) {
    List<String> phones = [phone1, phone2];
    phones.sort();
    return phones.join('_');
  }

  void _createNewChat(String contactPhone, String contactName) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final chatId = _getChatId(currentUser.phoneNumber!, contactPhone);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(
          chatId: chatId,
          contactName: contactName,
          contactPhone: contactPhone,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    return Container(
      color: Colors.grey[50],
      child: Column(
        children: [
          _buildQuickContacts(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .where(
                    'participants',
                    arrayContains: currentUser?.phoneNumber,
                  )
                  .orderBy('lastMessageTime', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No conversations yet',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[500],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start a new chat with someone!',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final chats = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    final data = chat.data() as Map<String, dynamic>;
                    final participants = List<String>.from(
                      data['participants'] ?? [],
                    );

                    // Get the other participant's phone number
                    final otherParticipant = participants.firstWhere(
                      (phone) => phone != currentUser?.phoneNumber,
                      orElse: () => '',
                    );

                    return _buildChatItem(
                      context,
                      index,
                      otherParticipant,
                      data['lastMessage'] ?? '',
                      data['lastMessageTime'],
                      chat.id,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickContacts() {
    final quickContacts = [
      {'name': 'Alice', 'phone': '+1234567890'},
      {'name': 'Bob', 'phone': '+1234567891'},
      {'name': 'Charlie', 'phone': '+1234567892'},
      {'name': 'Diana', 'phone': '+1234567893'},
    ];

    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: quickContacts.length,
        itemBuilder: (context, index) {
          final contact = quickContacts[index];
          return GestureDetector(
            onTap: () => _createNewChat(contact['phone']!, contact['name']!),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.blue[100],
                    child: Icon(
                      Icons.person,
                      color: Colors.blue[800],
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    contact['name']!,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatItem(
    BuildContext context,
    int index,
    String contactPhone,
    String lastMessage,
    dynamic timestamp,
    String chatId,
  ) {
    final bool hasUnread = index % 4 == 0;
    final int unreadCount = hasUnread ? index % 5 + 1 : 0;
    final contactName = contactPhone.isNotEmpty
        ? 'Contact ${contactPhone.substring(contactPhone.length - 2)}'
        : 'Unknown';

    String timeText = '';
    if (timestamp != null) {
      final date = timestamp.toDate();
      final now = DateTime.now();

      if (date.day == now.day &&
          date.month == now.month &&
          date.year == now.year) {
        timeText = '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      } else {
        timeText = '${date.day}/${date.month}';
      }
    }

    return ListTile(
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.blue[100],
        child: Icon(Icons.person, color: Colors.blue[800], size: 24),
      ),
      title: Text(
        contactName,
        style: GoogleFonts.poppins(
          fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w500,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        lastMessage.isNotEmpty ? lastMessage : 'Start a conversation',
        style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            timeText,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(height: 4),
          if (hasUnread && unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue[600],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                unreadCount.toString(),
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(
              chatId: chatId,
              contactName: contactName,
              contactPhone: contactPhone,
            ),
          ),
        );
      },
    );
  }
}
