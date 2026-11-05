import 'package:flutter/material.dart';

class PetPerfilPage extends StatefulWidget {
  const PetPerfilPage({super.key});

  @override
  State<PetPerfilPage> createState() => _PetPerfilPage();
}

class _PetPerfilPage extends State<PetPerfilPage> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Text('pet Page'),
          ],
        );
      },
    );
  }
}