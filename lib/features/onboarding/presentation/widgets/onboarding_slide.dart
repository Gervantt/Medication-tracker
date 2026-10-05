import 'package:flutter/material.dart';

class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({
    required this.icon,
    required this.title,
    required this.body,
    this.extra,
    super.key,
  });

  final IconData icon;
  final String title;
  final String body;

  /// Optional content below the text, e.g. the medical disclaimer.
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Icon(icon, size: 96, color: theme.colorScheme.primary),
          const SizedBox(height: 32),
          Text(
            title,
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            body,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          if (extra != null) ...[const SizedBox(height: 24), extra!],
        ],
      ),
    );
  }
}
