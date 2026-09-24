import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(const MeuApp());
}


class MeuApp extends StatelessWidget{
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true
      ),
      routes: AppRoutes.routes,
      home: const LoginPage(),
    );
  }  
}



