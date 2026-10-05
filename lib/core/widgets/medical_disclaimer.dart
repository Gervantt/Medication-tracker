import 'package:flutter/material.dart';
import 'package:medtrack/core/extensions/context_extensions.dart';

/// Reminds that the app does not replace a doctor's advice.
class MedicalDisclaimer extends StatelessWidget {
  const MedicalDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      color: colors.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: colors.onTertiaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.l10n.medicalDisclaimer,
                style: TextStyle(color: colors.onTertiaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
