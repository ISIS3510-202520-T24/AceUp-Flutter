import 'package:flutter/material.dart';

class HolidaysScreen extends StatelessWidget {
  const HolidaysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        title: const Text(
          "Holidays",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF201E1B), // Dark neutral for title
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFEAF4FF), // Light blue secondary
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF201E1B)), // dark icons
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 7, // example items
        itemBuilder: (context, index) {
          return Card(
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 6.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Color(0xFFEDEAE4)), // light neutral border
            ),
            child: ListTile(
              title: const Text(
                "[Holiday Name]",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF201E1B), // dark text
                ),
              ),
              subtitle: const Text(
                "[Date] or [Start Date] - [End Date]",
                style: TextStyle(
                  color: Color(0xFF797671), // neutral gray for subtitles
                ),
              ),
              trailing: const Icon(Icons.edit, size: 18, color: Color(0xFF797671)),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF50E3C2), // Primary green/teal
        onPressed: () {},
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }
}

