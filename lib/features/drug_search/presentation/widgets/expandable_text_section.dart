import 'package:flutter/material.dart';
import 'package:medtrack/core/extensions/context_extensions.dart';

/// Titled block of a long label text, collapsed to a few lines with a
/// "show more" toggle when the text does not fit.
class ExpandableTextSection extends StatefulWidget {
  const ExpandableTextSection({
    required this.title,
    required this.text,
    super.key,
  });

  final String title;
  final String text;

  @override
  State<ExpandableTextSection> createState() => _ExpandableTextSectionState();
}

class _ExpandableTextSectionState extends State<ExpandableTextSection> {
  static const _collapsedLines = 6;

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodyMedium;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final overflows = _overflows(context, style, constraints.maxWidth);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SelectableText with maxLines always reserves the height of
                // all lines, so selection comes from SelectionArea instead.
                SelectionArea(
                  child: Text(
                    widget.text,
                    style: style,
                    maxLines: _expanded ? null : _collapsedLines,
                    overflow: _expanded ? null : TextOverflow.ellipsis,
                  ),
                ),
                if (overflows || _expanded)
                  TextButton(
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    onPressed: () => setState(() => _expanded = !_expanded),
                    child: Text(
                      _expanded ? context.l10n.showLess : context.l10n.showMore,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  bool _overflows(BuildContext context, TextStyle? style, double maxWidth) {
    final painter = TextPainter(
      text: TextSpan(text: widget.text, style: style),
      maxLines: _collapsedLines,
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: maxWidth);
    final overflows = painter.didExceedMaxLines;
    painter.dispose();
    return overflows;
  }
}
