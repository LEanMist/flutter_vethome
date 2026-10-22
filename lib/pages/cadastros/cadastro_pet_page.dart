import 'package:flutter/material.dart';
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
          fields: const [
            VHField('Nome do Pet', Icons.person, value: 'Fernando'),
            VHField('Data de Nascimento', Icons.cake, value: '23/03/2012'),
            VHField('Tipo de Animal', Icons.pets, value: 'Cachorro', textCapitalization: TextCapitalization.characters,),
           VHField('Gênero/Sexo', Icons.person_outline, value: 'femea', textCapitalization: TextCapitalization.characters,),
            VHField('Raça', Icons.pets, value: 'Lulu-da-Pomerânia'),
            VHField('Peso',Icons.scale,value: '24',keyboardType: TextInputType.number,),
            VHField('CPF Cliente',Icons.tag,value: '754894724804',keyboardType: TextInputType.number),

          ],
          onSubmit: (data) async {
            final pet = {
              'nome': data['Nome do Pet'],
              'dataNasc': data['Data de Nascimento'],
              'especie': data['Tipo de Animal'] ,
              'sexo': data['Gênero/Sexo'], 
              'raca': data['Raça'],
              'peso': data['Peso'],
              'cpfCliente': data['CPF Cliente'],
              };

             await PetService.cadastrarPet(pet);
            
          },
        ),
      );
}

