import 'package:flutter/material.dart';

import '../../widgets/top_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
        title: 'Settings',
        leftControlType: LeftControlType.back,
      ),
      body: Center(
        child: Text(
          'Settings Screen',
        ),
      ),
    );
  }
}