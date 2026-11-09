import 'package:flutter/material.dart';

import '../pages/teste_page.dart';

/// Provides a development-only shortcut to jump between app screens.
class DebugScreenSwitcher extends StatefulWidget {
  const DebugScreenSwitcher({
    required this.child,
    required this.navigatorKey,
    super.key,
  });

  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<DebugScreenSwitcher> createState() => _DebugScreenSwitcherState();
}

class _DebugScreenSwitcherState extends State<DebugScreenSwitcher> {
  bool _pickerOpen = false;

  Future<void> _openPicker() async {
    final navigator = widget.navigatorKey.currentState;
    if (navigator == null || _pickerOpen) return;

    setState(() => _pickerOpen = true);
    try {
      final pageBuilder = await navigator.push<WidgetBuilder>(
        MaterialPageRoute<WidgetBuilder>(
          settings: const RouteSettings(name: '/__debug-screen-picker'),
          builder: (_) => const TestePage(selectionMode: true),
        ),
      );
      if (!mounted) return;
      setState(() => _pickerOpen = false);
      if (pageBuilder == null) return;

      await navigator.push<void>(
        MaterialPageRoute<void>(
          settings: const RouteSettings(name: '/__debug-screen-preview'),
          builder: pageBuilder,
        ),
      );
    } finally {
      if (mounted && _pickerOpen) setState(() => _pickerOpen = false);
    }
  }

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      widget.child,
      if (!_pickerOpen)
        Positioned(
          top: 12,
          right: 12,
          child: SafeArea(
            child: Material(
              color: Theme.of(context).colorScheme.primary,
              elevation: 5,
              shape: const CircleBorder(),
              child: Semantics(
                button: true,
                label: 'Escolher tela para teste',
                onTap: _openPicker,
                child: InkWell(
                  key: const ValueKey('debug-screen-switcher-button'),
                  customBorder: const CircleBorder(),
                  onTap: _openPicker,
                  child: SizedBox.square(
                    dimension: 48,
                    child: Icon(
                      Icons.grid_view_rounded,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
    ],
  );
}
