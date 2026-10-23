import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/vet_repository.dart';
import 'pages/critical_storage_error_page.dart';
import 'routes/app_routes.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await VetRepository.initialize();
  runApp(const VetHomeApp());
}

class VetHomeApp extends StatefulWidget {
  const VetHomeApp({super.key});

  @override
  State<VetHomeApp> createState() => _VetHomeAppState();
}

class _VetHomeAppState extends State<VetHomeApp> {
  // Nova leitura (sem gravação); reconstrói o app para refletir o novo status.
  Future<void> _retryStorage() async {
    await VetRepository.retryInitialization();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: VH.themeSeed,
      builder: (context, themeSeed, _) {
        if (VetRepository.persistenceBlocked) {
          return MaterialApp(
            // Chaves distintas recriam o Navigator ao sair do bloqueio.
            key: const ValueKey('vethome-blocked-app'),
            debugShowCheckedModeBanner: false,
            title: 'Vet Home',
            locale: const Locale('pt', 'BR'),
            supportedLocales: const [Locale('pt', 'BR')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            theme: VetTheme.light(themeSeed),
            home: CriticalStorageErrorPage(
              status: VetRepository.persistenceStatus,
              onRetry: _retryStorage,
            ),
          );
        }
        return MaterialApp(
          key: const ValueKey('vethome-app'),
          debugShowCheckedModeBanner: false,
          title: 'Vet Home',
          locale: const Locale('pt', 'BR'),
          supportedLocales: const [Locale('pt', 'BR')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          theme: VetTheme.light(themeSeed),
          initialRoute: '/',
          routes: AppRoutes.routes,
        );
      },
    );
  }
}
