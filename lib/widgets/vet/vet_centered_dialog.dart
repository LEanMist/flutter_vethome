import 'package:flutter/material.dart';

import '../../theme/vet_colors.dart';

/// Pop-up centralizado que permite rolar o conteúdo em janelas menores.
Future<T?> showVetCenteredDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) => showDialog<T>(
  context: context,
  builder: (context) => Dialog(
    alignment: Alignment.center,
    backgroundColor: VetColors.pink,
    insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
    constraints: const BoxConstraints(maxWidth: 390),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    clipBehavior: Clip.antiAlias,
    child: SingleChildScrollView(child: builder(context)),
  ),
);
