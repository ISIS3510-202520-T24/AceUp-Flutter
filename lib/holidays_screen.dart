import 'package:flutter/material.dart';

class HolidaysScreen extends StatelessWidget {
  const HolidaysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE7EEF6),
        title: const Text(
          'Holidays',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: 7, // 7 placeholders like your mockup
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              title: const Text(
                '[Holiday Name]',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              subtitle: const Text(
                '[Date]\n[Start Date] - [End Date]',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              isThreeLine: true,
              trailing: IconButton(
                icon: const Icon(Icons.edit, size: 20, color: Colors.black54),
                onPressed: () {},
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2ED5AE),
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
