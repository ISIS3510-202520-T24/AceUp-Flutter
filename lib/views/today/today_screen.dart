import 'package:flutter/material.dart';
import '../../widgets/burger_menu.dart';
import '../../widgets/top_bar.dart';
import '../../themes/app_colors.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textStyles = theme.textTheme;

    return Scaffold(
      drawer: const BurgerMenu(),
      appBar: TopBar(
        title: "Today",
        leftControlType: LeftControlType.menu,
        rightControlType: RightControlType.none,
      ),
      body: Column(
        children: [
          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Exams", style: TextStyle(color: AppColors.darkLightest)),
                const SizedBox(width: 16),
                const Text("Timetable", style: TextStyle(color: AppColors.darkLightest)),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.mintDark,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    "Assignments",
                    style: TextStyle(
                      color: AppColors.blueDarkest,
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
              color: AppColors.blueLightest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.image, size: 40, color: AppColors.blueLight),
          ),

          const SizedBox(height: 24),

          // Texts
          const Text(
            "You have no assignments due for the next 7 days",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.blueDarkest,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            "Time to work on a hobby of yours!",
            style: TextStyle(
              fontSize: 14,
              color: AppColors.blueDark,
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.mintDark,
        onPressed: () {},
        child: const Icon(Icons.add, size: 28, color: AppColors.blueDarkest),
      ),
    );
  }
}


