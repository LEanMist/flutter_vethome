import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/local_data_manager.dart';
import 'data/theme_preferences.dart';
import 'data/vet_repository.dart';
import 'pages/critical_storage_error_page.dart';
import 'routes/app_routes.dart';
import 'theme.dart';
import 'widgets/debug_screen_switcher.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await VetRepository.initialize();
  await ThemePreferences.load();
  runApp(const VetHomeApp());
}

class VetHomeApp extends StatefulWidget {
  const VetHomeApp({super.key});

  @override
  State<VetHomeApp> createState() => _VetHomeAppState();
}

class _VetHomeAppState extends State<VetHomeApp> {
  final _criticalNavigatorKey = GlobalKey<NavigatorState>();
  final _navigatorKey = GlobalKey<NavigatorState>();

  // Nova leitura (sem gravação); reconstrói o app para refletir o novo status.
  Future<void> _retryStorage() async {
    await VetRepository.retryInitialization();
    if (mounted) setState(() {});
  }

  Future<bool> _clearLocalData() async {
    final cleared = await LocalDataManager.clearUserData();
    if (cleared && mounted) setState(() {});
    return cleared;
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
            navigatorKey: _criticalNavigatorKey,
            builder: (context, child) => kDebugMode
                ? DebugScreenSwitcher(
                    navigatorKey: _criticalNavigatorKey,
                    child: child ?? const SizedBox.shrink(),
                  )
                : child ?? const SizedBox.shrink(),
            home: CriticalStorageErrorPage(
              status: VetRepository.persistenceStatus,
              onRetry: _retryStorage,
              onClear: _clearLocalData,
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
          navigatorKey: _navigatorKey,
          builder: (context, child) => kDebugMode
              ? DebugScreenSwitcher(
                  navigatorKey: _navigatorKey,
                  child: child ?? const SizedBox.shrink(),
                )
              : child ?? const SizedBox.shrink(),
          initialRoute: '/',
          routes: AppRoutes.routes,
        );
      },
    );
  }
}
