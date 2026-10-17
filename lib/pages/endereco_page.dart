import 'package:flutter/material.dart';

import '../data/vet_repository.dart';
import '../data/cep_service.dart';
import '../widgets/address_form.dart';
import '../theme.dart';

class EnderecoScreen extends StatelessWidget {
  const EnderecoScreen({
    super.key,
    this.initialData = const {},
    this.cepService = const CepService(),
  });
  final Map<String, String> initialData;
  final CepService cepService;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: VH.background,
    body: SafeArea(
      child: AddressForm(
        cepService: cepService,
        title: 'Endereço',
        onSaved: (address) {
          final data = {
            ...initialData,
            'client.CEP': address.cep,
            'client.Endereço': address.street,
            'client.Cidade': address.city,
            'client.Número': address.number,
            'client.Complemento': address.complement,
          };
          VetRepository.registerClient(data);
          Navigator.pushNamed(context, '/cadastroPet', arguments: data);
        },
        onSkip: () {
          VetRepository.registerClient(initialData);
          Navigator.pushNamed(context, '/cadastroPet', arguments: initialData);
        },
      ),
    ),
  );
}
