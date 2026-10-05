import 'package:flutter/material.dart';
import 'package:medtrack/core/extensions/context_extensions.dart';

/// Temporary body for screens that are implemented in later stages.
class PlaceholderView extends StatelessWidget {
  const PlaceholderView({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(context.l10n.comingSoon)),
    );
  }
}
