import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:talka/screens/status_screen.dart';
import 'package:talka/screens/calls_screen.dart';
import 'package:talka/screens/profile_screen.dart';

import 'chat_detail_screen.dart';
import 'chat_screen.dart';
import 'local_contacts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ChatsScreen(),
    const StatusScreen(),
    const CallsScreen(),
    const ProfileScreen(),
  ];

  final List<String> _appBarTitles = ['Talka', 'Status', 'Calls', 'Profile'];

  String _getChatId(String phone1, String phone2) {
    List<String> phones = [phone1, phone2];
    phones.sort();
    return phones.join('_');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _appBarTitles[_currentIndex],
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions:
            _currentIndex ==
                0 // Only show search in Chats tab
            ? [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.grey),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.add_comment, color: Colors.grey),
                  onPressed: () {},
                ),
              ]
            : null,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blue[600],
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: _currentIndex == 0
                    ? BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      )
                    : null,
                child: Icon(
                  _currentIndex == 0 ? Icons.chat : Icons.chat_outlined,
                  size: 24,
                ),
              ),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: _currentIndex == 1
                    ? BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      )
                    : null,
                child: Icon(
                  _currentIndex == 1
                      ? Icons.auto_awesome
                      : Icons.auto_awesome_outlined,
                  size: 24,
                ),
              ),
              label: 'Status',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: _currentIndex == 2
                    ? BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      )
                    : null,
                child: Icon(
                  _currentIndex == 2 ? Icons.call : Icons.call_outlined,
                  size: 24,
                ),
              ),
              label: 'Calls',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: _currentIndex == 3
                    ? BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      )
                    : null,
                child: Icon(
                  _currentIndex == 3 ? Icons.person : Icons.person_outline,
                  size: 24,
                ),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget? _buildFloatingActionButton() {
    switch (_currentIndex) {
      case 0: // Chats
        return FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LocalContactsScreen(),
              ),
            );
          },
          backgroundColor: Colors.blue[600],
          child: const Icon(Icons.chat, color: Colors.white),
        );
    }
  }
}
