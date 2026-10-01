import 'package:flutter/material.dart';

class ContatoPage extends StatefulWidget {
  const ContatoPage({super.key});

  @override
  State<ContatoPage> createState() => _ContatoPage();
}

class _ContatoPage extends State<ContatoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Contato Page'),
      ),
    );
  }
}