import 'package:flutter/material.dart';

import '../data/vet_repository.dart';
import '../data/cep_service.dart';
import '../core/utils/form_fields.dart';
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

  Future<void> _continue(BuildContext context, Map<String, String> data) async {
    VetRepository.registerClient(data);
    final saved = await VetRepository.flush();
    if (!context.mounted) return;
    if (!saved) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Dados atualizados nesta sessão. Não foi possível salvar localmente.',
            ),
          ),
        );
    }
    Navigator.pushNamed(
      context,
      '/cadastroPet',
      arguments: saved
          ? {
              for (final entry in data.entries)
                if (!entry.key.startsWith('client.')) entry.key: entry.value,
            }
          : data,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: VH.background,
    body: SafeArea(
      top: MediaQuery.sizeOf(context).width >= VH.desktopBreakpoint,
      child: AddressForm(
        cepService: cepService,
        title: 'Endereço',
        onSaved: (address) async {
          final data = withoutRegistrationPasswords({
            ...initialData,
            'client.CEP': address.cep,
            'client.Endereço': address.street,
            'client.Nome do Endereço': address.name,
            'client.Cidade': address.city,
            'client.Número': address.number,
            'client.Complemento': address.complement,
          });
          await _continue(context, data);
        },
        onSkip: () async {
          final data = withoutRegistrationPasswords(initialData);
          await _continue(context, data);
        },
      ),
    ),
  );
}
