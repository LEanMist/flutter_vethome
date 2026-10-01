import 'package:flutter/material.dart';

import 'app_routes.dart';

void main() {
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VetHome',
      navigatorKey: navigatorKey,
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
