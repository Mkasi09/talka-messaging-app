import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CallsScreen extends StatelessWidget {
  const CallsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8),
        itemCount: 12,
        itemBuilder: (context, index) {
          return _buildCallItem(context, index);
        },
      ),
    );
  }

  Widget _buildCallItem(BuildContext context, int index) {
    final bool isMissed = index % 5 == 0;
    final bool isOutgoing = index % 3 == 0;
    final callType = isOutgoing ? Icons.call_made : Icons.call_received;

    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.blue[100],
        child: Icon(Icons.person, color: Colors.blue[800], size: 20),
      ),
      title: Text(
        'Contact ${index + 1}',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: isMissed ? Colors.red : Colors.black,
        ),
      ),
      subtitle: Row(
        children: [
          Icon(callType, size: 14, color: isMissed ? Colors.red : Colors.green),
          const SizedBox(width: 4),
          Text(
            '${(index % 12) + 1}:${(index % 60).toString().padLeft(2, '0')} ${index % 2 == 0 ? 'AM' : 'PM'}',
            style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
      trailing: IconButton(
        icon: Icon(Icons.call, color: Colors.blue[600], size: 24),
        onPressed: () {
          // Initiate call
        },
      ),
      onTap: () {
        // Show call details or initiate call
      },
    );
  }
}
