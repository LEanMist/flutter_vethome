import 'package:flutter/material.dart';

class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({super.key});

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPage();
}

class _ConfiguracoesPage extends State<ConfiguracoesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Configuracoes Page'),
      ),
    );
  }
}