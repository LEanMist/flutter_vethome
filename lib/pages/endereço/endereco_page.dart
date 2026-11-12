import 'package:flutter/material.dart';

import '../../data/cep_service.dart';
import '../../models/saved_address.dart';
import '../../service/endereco_service.dart';
import '../../theme.dart';
import '../../widgets/address_form.dart';

class EnderecoScreen extends StatelessWidget {
  const EnderecoScreen({
    super.key,
    this.initialData = const {},
    this.cepService = const CepService(),
  });

  final Map<String, String> initialData;
  final CepService cepService;

  Map<String, String> _nextData(SavedAddress address) {
    final nextData = <String, String>{...initialData};
    nextData['CEP'] = address.cep;
    nextData['Endereço'] = address.street;
    nextData['Nome do Endereço'] = address.name;
    nextData['Cidade'] = address.city;
    nextData['Número'] = address.number;
    nextData['Complemento'] = address.complement;
    return nextData;
  }

  void _continue(BuildContext context, Map<String, String> data) {
    if (!context.mounted) return;
    Navigator.pushNamed(context, '/cadastroPet', arguments: data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VH.background,
      body: SafeArea(
        top: MediaQuery.sizeOf(context).width >= VH.desktopBreakpoint,
        child: AddressForm(
          cepService: cepService,
          title: 'Endereço',
          skipButtonStyle: TextButton.styleFrom(
            foregroundColor: VH.foreground,
            textStyle: const TextStyle(
              fontFamily: VH.bodyFontFamily,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          onSaved: (address) {
            EnderecoService.saveAddress(address);
            _continue(context, _nextData(address));
          },
          onSkip: () {
            _continue(context, Map<String, String>.from(initialData));
          },
        ),
      ),
    );
  }
}
