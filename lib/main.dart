import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/vet_repository.dart';
import 'routes/app_routes.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await VetRepository.initialize();
  runApp(const VetHomeApp());
}

class VetHomeApp extends StatelessWidget {
  const VetHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: VH.themeSeed,
      builder: (context, themeSeed, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Vet Home',
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: VetTheme.light(themeSeed),
        initialRoute: '/',
        routes: AppRoutes.routes,
      ),
    );
  }
}
