import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [WelcomeCard(), const SizedBox(height: 12),
        QuickActionsRow(), const SizedBox(height: 12)],
      ),
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

class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: QuickActionsCard(
            title: 'AI Assistant',
            subtitle: 'get real-time help',
            QAIcon: Icons.smart_toy_outlined,
            QAroute: '/assistant',
          ),
        ),

        SizedBox(width: 12),
        Expanded(
          child: QuickActionsCard(
            title: 'Emergency',
            subtitle: 'Quick help access',
            QAIcon: Icons.call,
            QAroute: '/emergency',
            emph: true,
          ),
        ),
      ],
    );
  }
}

class QuickActionsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData QAIcon;
  final String QAroute;
  final bool emph;
  const QuickActionsCard({
    required this.title,
    required this.subtitle,
    required this.QAIcon,
    required this.QAroute,
    this.emph = false,
  });

  @override
  Widget build(BuildContext context) {
    final Scheme = Theme.of(context).colorScheme;
    final bg = emph ? Scheme.errorContainer : Scheme.surface;
    final fg = emph ? Scheme.onErrorContainer : Scheme.onSurface;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).pushNamed(QAroute),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(QAIcon, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontWeight: FontWeight.w700, color: fg),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(color: fg.withOpacity(0.7)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
