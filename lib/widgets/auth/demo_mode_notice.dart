import 'package:flutter/material.dart';

import '../../theme.dart';

class DemoModeNotice extends StatelessWidget {
  const DemoModeNotice({
    super.key,
    required this.message,
    this.compact = false,
    this.semanticLabel,
  });

  final String message;
  final bool compact;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: semanticLabel ?? message,
    child: ExcludeSemantics(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 14,
          vertical: compact ? 4 : 11,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .58),
          border: Border.all(color: VH.secondary.withValues(alpha: .65)),
          borderRadius: BorderRadius.circular(compact ? 20 : 16),
        ),
        child: Row(
          mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: compact ? 1 : 0),
              child: Icon(
                Icons.info_outline_rounded,
                color: VH.foreground,
                size: compact ? 16 : 18,
              ),
            ),
            SizedBox(width: compact ? 7 : 9),
            Flexible(
              child: Text(
                message,
                maxLines: compact ? 1 : null,
                overflow: compact ? TextOverflow.ellipsis : null,
                style: TextStyle(
                  fontFamily: VH.bodyFontFamily,
                  color: VH.foreground,
                  fontSize: compact ? 11 : 12,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
