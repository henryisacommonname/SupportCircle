import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(padding: const EdgeInsets.all(16), children: [
        WelcomeCard(),
        const SizedBox(height: 12),
      ]),
    );
  }
}
/*--- Components ---*/
class WelcomeCard extends StatelessWidget {
  const WelcomeCard();
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to SupportCircle',
              style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'supporting children and family together',
              style: text.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class QuickActionsQuotes