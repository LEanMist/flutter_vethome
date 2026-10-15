import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../widgets.dart';

class EnderecoScreen extends StatelessWidget {
  const EnderecoScreen({super.key, this.initialData = const {}});

  final Map<String, String> initialData;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: VH.background,
        body: VHForm(
          title: 'Endereço',
          next: '/cadastroPet',
          initialData: initialData,
          fields: const [
            VHField(
              'CEP',
              Icons.home,
              value: '34556-234',
              keyboardType: TextInputType.number,
            ),
            VHField('Endereço', Icons.home, value: 'R. Carcino'),
            VHField(
              'Número',
              Icons.tag,
              value: '73',
              keyboardType: TextInputType.number,
            ),
            VHField('Complemento', Icons.home),
            VHField('Cidade', Icons.location_city),
          ],
        ),
      );
}