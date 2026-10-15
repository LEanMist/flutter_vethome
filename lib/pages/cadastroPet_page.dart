import 'package:flutter/material.dart';
import '../data/vet_repository.dart';
import '../service/cliente_service.dart';
import '../theme.dart';
import '../widgets.dart';

class CadastroPetScreen extends StatelessWidget {
  const CadastroPetScreen({super.key, this.initialData = const {}});

  final Map<String, String> initialData;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: VH.background,
        body: VHForm(
          title: 'Cadastro Pet',
          next: '/sucesso',
          initialData: initialData,
          fields: const [
            VHField('Tipo de Animal', Icons.pets, value: 'Cachorro'),
            VHField('Nome do Pet', Icons.person, value: 'Fernando'),
            VHField('Gênero/Sexo', Icons.person_outline, value: 'M'),
            VHField(
              'Peso',
              Icons.scale,
              value: '24',
              keyboardType: TextInputType.number,
            ),
            VHField('Data de Nascimento', Icons.cake, value: '23/03/2012'),
            VHField('Raça', Icons.pets, value: 'Lulu-da-Pomerânia'),
          ],
          onSubmit: (data) async {
            try {
              await ClienteService.cadastrarCliente(data);
              final weight = double.parse(data['Peso']!.replaceAll(',', '.'));
              final birth = _parseDate(data['Data de Nascimento']!);

              VetRepository.addPet(
                name: data['Nome do Pet']!,
                species: data['Tipo de Animal']!,
                sex: data['Gênero/Sexo']!,
                weightKg: weight,
                birthDate: birth,
                breed: data['Raça']!,
              );

              if (data.containsKey('E-mail')) {
                VetRepository.registerClient(data);
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro no cadastro: $e')),
                );
              }
            }
          },
        ),
      );

  static DateTime _parseDate(String value) {
    final parts = value.split(RegExp(r'[/.-]')).map(int.parse).toList();
    return parts[0] > 31
        ? DateTime(parts[0], parts[1], parts[2])
        : DateTime(parts[2], parts[1], parts[0]);
  }
}

