import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_detail_screen.dart';

class LocalContactsScreen extends StatefulWidget {
  const LocalContactsScreen({super.key});

  @override
  State<LocalContactsScreen> createState() => _LocalContactsScreenState();
}

class _LocalContactsScreenState extends State<LocalContactsScreen> {
  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  Map<String, String> _appUsersMap = {}; // phone -> displayName
  bool _loading = true;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContactsAndUsers();
    _searchController.addListener(_filterContacts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContactsAndUsers() async {
    final permission = await FlutterContacts.requestPermission();
    if (!permission) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission denied to read contacts')),
      );
      return;
    }

    final contacts = await FlutterContacts.getContacts(withProperties: true);
    final localContacts = contacts.where((c) => c.phones.isNotEmpty).toList();

    final querySnapshot = await _firestore.collection('users').get();
    Map<String, String> usersMap = {};
    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      if (data['phone'] != null && data['name'] != null) {
        usersMap[data['phone']] = data['name'];
      }
    }

    setState(() {
      _contacts = localContacts;
      _filteredContacts = List.from(_contacts);
      _appUsersMap = usersMap;
      _loading = false;
    });
  }

  void _filterContacts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredContacts = _contacts
          .where(
            (c) =>
                c.displayName.toLowerCase().contains(query) ||
                c.phones.any((p) => p.number.contains(query)),
          )
          .toList();
    });
  }

  String _normalizePhone(String phone) {
    phone = phone.replaceAll(RegExp(r'\s+|\-|\(|\)'), '');
    if (phone.startsWith('0')) {
      phone = phone.replaceFirst('0', '+27'); // adjust your country code
    }
    return phone;
  }

  String _getChatId(String phone1, String phone2) {
    List<String> phones = [phone1, phone2];
    phones.sort();
    return phones.join('_');
  }

  void _startChat(String contactPhone, String contactName) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final normalizedPhone = _normalizePhone(contactPhone);

    if (!_appUsersMap.containsKey(normalizedPhone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$contactName is not registered in the app')),
      );
      return;
    }

    final chatId = _getChatId(currentUser.phoneNumber!, normalizedPhone);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(
          chatId: chatId,
          contactName: contactName,
          contactPhone: normalizedPhone,
        ),
      ),
    );
  }

  Future<void> _addNewContact() async {
    try {
      final newContact = Contact()
        ..name.first = ''
        ..phones = [Phone('')];

      await FlutterContacts.insertContact(newContact);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('New contact added')));

      _loadContactsAndUsers(); // reload contacts and app users
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to add contact')));
    }
  }

  Widget _buildContactsList() {
    return ListView.builder(
      itemCount: _filteredContacts.length,
      itemBuilder: (context, index) {
        final contact = _filteredContacts[index];
        final phoneNumber = contact.phones.isNotEmpty
            ? contact.phones.first.number
            : '';
        final normalizedPhone = _normalizePhone(phoneNumber);
        final isRegistered = _appUsersMap.containsKey(normalizedPhone);

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue[100],
            child: Icon(Icons.person, color: Colors.blue[800]),
          ),
          title: Text(
            contact.displayName,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: isRegistered ? Colors.black : Colors.grey,
            ),
          ),
          subtitle: Text(
            phoneNumber,
            style: TextStyle(color: isRegistered ? Colors.black : Colors.grey),
          ),
          trailing: isRegistered
              ? const Icon(Icons.chat, color: Colors.green)
              : const Icon(Icons.block, color: Colors.grey),
          onTap: isRegistered
              ? () => _startChat(phoneNumber.trim(), contact.displayName)
              : null,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'No contacts found',
        style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Contacts',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _addNewContact,
            tooltip: 'Add New Contact',
          ),
        ],
      ),
      body: _loading
          ? _buildLoadingState()
          : _filteredContacts.isEmpty
          ? _buildEmptyState()
          : _buildContactsList(),
    );
  }
}
