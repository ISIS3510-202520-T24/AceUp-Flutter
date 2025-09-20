import 'package:flutter/material.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        title: const Text(
          "Today",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF201E1B), // dark text
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFEAF4FF), // light blue secondary
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF201E1B)),
      ),
      body: Column(
        children: [
          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Exams", style: TextStyle(color: Color(0xFF797671))),
                const SizedBox(width: 16),
                Text("Timetable", style: TextStyle(color: Color(0xFF797671))),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFF50E3C2), // primary
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    "Assignments",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 60),

          // Center Image Placeholder
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Color(0xFFEAF4FF), // same blue background
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.image, size: 40, color: Color(0xFF97948E)),
          ),

          const SizedBox(height: 24),

          // Texts
          const Text(
            "You have no assignments\ndue for the next 7 days",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF201E1B), // dark
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            "Time to work on a hobby of yours!",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF797671), // neutral gray
            ),
          ),
        ],
      ),

      // Floating Add Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF50E3C2),
        onPressed: () {},
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }
}

