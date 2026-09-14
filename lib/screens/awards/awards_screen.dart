import 'package:flutter/material.dart';
import '../../widgets/shared/coming_soon_screen.dart';

class AwardsScreen extends StatelessWidget {
  const AwardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScreen(
      title: 'Awards & Offers',
      icon: Icons.emoji_events_outlined,
    );
  }
}
