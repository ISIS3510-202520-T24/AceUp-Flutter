// lib/shared_screen.dart

import 'package:flutter/material.dart';

// Data model to represent a group
class SharedGroup {
  final String name;
  final List<String> members;
  final Color color;

  SharedGroup({required this.name, required this.members, required this.color});
}

class SharedScreen extends StatefulWidget {
  const SharedScreen({super.key});

  @override
  State<SharedScreen> createState() => _SharedScreenState();
}

class _SharedScreenState extends State<SharedScreen> {
  // List of groups
  final List<SharedGroup> _groups = [
    SharedGroup(name: 'Family Group', members: ['Ana', 'Juan', 'Luis'], color: const Color(0xFF2C3E50)),
    SharedGroup(name: 'University Project', members: ['Maria', 'Pedro', 'Sofia'], color: const Color(0xFF2C3E50)),
    SharedGroup(name: 'Weekend Friends', members: ['Carlos', 'Elena', 'Marco'], color: const Color(0xFF2C3E50)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Background color of the app bar
        backgroundColor: const Color(0xFFC3D2E4),
        // App bar shadow
        elevation: 0,
        // Screen title
        title: const Text(
          'Shared',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        // Menu icon on the left
        leading: IconButton(
          icon: const Icon(
            Icons.menu,
            color: Color(0xFF2C3E50),
          ),
          onPressed: () {
            // Action for the menu button
          },
        ),
      ),
      // Main body of the screen
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Container to display the total number of groups
            _buildTotalGroupsCard(),
            const SizedBox(height: 30),
            // Title for the shared calendars section
            const Text(
              'Shared Calendars',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 20),
            // Expandable list of groups
            Expanded(
              child: ListView.builder(
                itemCount: _groups.length,
                itemBuilder: (context, index) {
                  return _buildGroupListItem(_groups[index]);
                },
              ),
            ),
          ],
        ),
      ),
      // Floating action button to add new groups
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action to add a new group
        },
        backgroundColor: const Color(0xFF66DDC5),
        child: const Icon(Icons.add, color: Colors.black),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
    );
  }

  // Widget for the "Total Groups" card
  Widget _buildTotalGroupsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total Groups:',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            _groups.length.toString(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // Widget for each group list item
  Widget _buildGroupListItem(SharedGroup group) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: group.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  group.members.join(' '),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey,
            size: 16,
          ),
        ],
      ),
    );
  }
}
