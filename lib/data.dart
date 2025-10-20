class Chat {
  final String name;
  final String lastMessage;
  final String time;
  final String avatar;

  const Chat({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.avatar,
  });
}

class Message {
  final String text;
  final bool isMe;
  final String time;

  const Message({required this.text, required this.isMe, required this.time});
}

// Mock data
final List<Chat> mockChats = [
  Chat(
    name: 'John Doe',
    lastMessage: 'Hey, how are you doing?',
    time: '10:30 AM',
    avatar: 'assets/avatars/avatar1.png',
  ),
  Chat(
    name: 'Sarah Smith',
    lastMessage: 'Lets meet at the cafe 🚗',
    time: '9:15 AM',
    avatar: 'assets/avatars/avatar2.png',
  ),
  Chat(
    name: 'Mike Johnson',
    lastMessage: 'Did you finish the project?',
    time: 'Yesterday',
    avatar: 'assets/avatars/avatar3.png',
  ),
  Chat(
    name: 'Emily Davis',
    lastMessage: '😂😂😂',
    time: 'Yesterday',
    avatar: 'assets/avatars/avatar4.png',
  ),
];

final List<Message> mockMessages = [
  Message(text: 'Hey there! How are you doing?', isMe: false, time: '10:25 AM'),
  Message(
    text: 'Im good! Just working on the new project.',
    isMe: true,
    time: '10:26 AM',
  ),
  Message(
    text: 'Thats great! We should discuss the details sometime.',
    isMe: false,
    time: '10:28 AM',
  ),
  Message(
    text: 'Sure, lets meet tomorrow at 3 PM?',
    isMe: true,
    time: '10:29 AM',
  ),
  Message(text: 'Perfect! See you then 👋', isMe: false, time: '10:30 AM'),
];
