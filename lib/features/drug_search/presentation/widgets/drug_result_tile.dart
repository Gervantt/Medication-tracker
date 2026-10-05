import 'package:flutter/material.dart';
import 'package:medtrack/core/extensions/context_extensions.dart';
import 'package:medtrack/features/drug_search/domain/entities/drug_label.dart';

class DrugResultTile extends StatelessWidget {
  const DrugResultTile({required this.label, this.onTap, super.key});

  final DrugLabel label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final details = [
      if (label.brandName != null) label.genericName,
      label.manufacturer,
    ].nonNulls.join('\n');
    return ListTile(
      leading: const Icon(Icons.medication_liquid_outlined),
      title: Text(label.name ?? context.l10n.drugUnnamed),
      subtitle: details.isEmpty ? null : Text(details),
      isThreeLine: details.contains('\n'),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
