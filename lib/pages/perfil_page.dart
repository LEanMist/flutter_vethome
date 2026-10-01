import 'package:flutter/material.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPage();
}

class _PerfilPage extends State<PerfilPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Perfil Page'),
      ),
    );
  }
}