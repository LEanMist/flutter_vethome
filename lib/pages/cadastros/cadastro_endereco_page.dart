import 'package:flutter/material.dart';
import '../../service/endereco_service.dart';
import '../../theme.dart';
import '../../widgets.dart';

class EnderecoScreen extends StatelessWidget {
  const EnderecoScreen({super.key, this.initialData = const {}});

  final Map<String, String> initialData;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: VH.background,
        body: VHForm(
          title: 'Endereço',
          next: '/sucesso',
          initialData: initialData,
          fields: const [
            VHField('CEP',Icons.home, value: '34556-234', keyboardType: TextInputType.number,),
            VHField('Logradouro', Icons.home, value: 'R. Carcino'),
            VHField('Complemento', Icons.home),
            VHField('Bairro', Icons.home, value: 'Centro'),
            VHField('Cidade', Icons.location_city),
            VHField('Número',Icons.tag,value: '73',keyboardType: TextInputType.number),
            VHField('CPF Cliente',Icons.tag,value: '754894724804',keyboardType: TextInputType.number),
          ],
          onSubmit: (data) async{
              final endereco = {
              'cep': data['CEP'],
              'logradouro': data['Logradouro'],
              'complemento': data['Complemento'] ?? '',
              'bairro': data['Bairro'],
              'cidade': data['Cidade'],
              'numero': data['Número'],
              'cpfCliente': data['CPF Cliente'],
              };

             await EnderecoService.cadastrarEndereco(endereco);
          }
        ),
      );
}

