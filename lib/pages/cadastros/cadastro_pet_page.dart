import 'package:flutter/material.dart';
import '../../models/animal_enums.dart';
import '../../service/pet_service.dart';
import '../../theme.dart';
import '../../widgets.dart';

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
          fields: [
            const VHField('Nome do Pet', Icons.person),
            const VHField('Data de Nascimento', Icons.cake),
            VHField(
              'Tipo de Animal',
              Icons.pets,
              options: AnimalType.values
                  .map((animal) => animal.label)
                  .toList()
                  .map((s) => s.toUpperCase())
                  .toList(),
            ),
            VHField(
              'Gênero/Sexo',
              Icons.person_outline,
              options: AnimalSex.values
                  .map((animal) => animal.label)
                  .toList()
                  .map((s) => s.toUpperCase())
                  .toList(),
            ),
            const VHField('Raça', Icons.pets),
            const VHField(
              'Peso',
              Icons.scale,
              keyboardType: TextInputType.number,
            ),
            const VHField(
              'CPF Cliente',
              Icons.tag,
              keyboardType: TextInputType.number,
            ),
          ],
          onSubmit: (data) async {
            String normalizeEnum(String? value) {
              final cleaned = (value ?? '').trim();
              if (cleaned.isEmpty) return '';

              return cleaned
                  .toUpperCase()
                  .replaceAll('Â', 'A')
                  .replaceAll('À', 'A')
                  .replaceAll('Á', 'A')
                  .replaceAll('Ã', 'A')
                  .replaceAll('Ê', 'E')
                  .replaceAll('È', 'E')
                  .replaceAll('É', 'E')
                  .replaceAll('Î', 'I')
                  .replaceAll('Ì', 'I')
                  .replaceAll('Í', 'I')
                  .replaceAll('Ô', 'O')
                  .replaceAll('Ò', 'O')
                  .replaceAll('Ó', 'O')
                  .replaceAll('Õ', 'O')
                  .replaceAll('Û', 'U')
                  .replaceAll('Ù', 'U')
                  .replaceAll('Ú', 'U')
                  .replaceAll('Ç', 'C');
            }

            final pet = {
              'nome': data['Nome do Pet'],
              'dataNasc': data['Data de Nascimento'],
              'especie': normalizeEnum(data['Tipo de Animal']),
              'sexo': normalizeEnum(data['Gênero/Sexo']),
              'raca': data['Raça'],
              'peso': data['Peso'],
              'cpfCliente': data['CPF Cliente'],
            };

            await PetService.cadastrarPet(pet);
          },
        ),
      );
}

