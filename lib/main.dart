import 'package:flutter/material.dart';
import 'package:flutter_vethome/pages/Informacoes_page.dart';
import 'package:flutter_vethome/pages/login_page.dart';
import 'pages/pets_page.dart';

void main() {
  runApp(const MeuApp());
}


class MeuApp extends StatelessWidget{
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pets',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true
      ),
      home: const PetsPage
      (),
    );
  }  
}



