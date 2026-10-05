import 'package:flutter/material.dart';
import 'package:medtrack/core/extensions/context_extensions.dart';
import 'package:medtrack/core/widgets/empty_view.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({this.message, this.onRetry, super.key});

  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return EmptyView(
      icon: Icons.error_outline,
      title: l10n.errorTitle,
      message: message ?? l10n.errorGenericMessage,
      action: onRetry == null
          ? null
          : FilledButton.tonal(onPressed: onRetry, child: Text(l10n.retry)),
    );
  }
}
