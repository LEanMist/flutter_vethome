import 'package:flutter/material.dart';

class AgendamentoPage extends StatefulWidget {
  const AgendamentoPage({super.key});

  @override
  State<AgendamentoPage> createState() => _AgendamentoPage();
}

class _AgendamentoPage extends State<AgendamentoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Agendamento Page'),
      ),
    );
  }
}