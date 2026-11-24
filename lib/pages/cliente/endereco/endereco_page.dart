import 'package:flutter/material.dart';

import '../../../data/vet_repository.dart';
import '../../../data/session.dart';
import '../../../models/saved_address.dart';
import '../../../service/endereco_service.dart';
import '../../../service/cep_service.dart';
import '../../../core/utils/form_fields.dart';
import '../../../widgets/address_form.dart';
import '../../../widgets/auth/local_profile_conflict_dialog.dart';
import '../../../theme.dart';
import '../cadastro_page.dart';

class EnderecoScreen extends StatelessWidget {
  const EnderecoScreen({
    super.key,
    this.initialData = const {},
    this.cepService = const CepService(),
  });
  final Map<String, String> initialData;
  final CepService cepService;

  Future<void> _continue(BuildContext context, Map<String, String> data) async {
    if (VetRepository.hasLocalClientIdentityConflict(
      email: data['client.E-mail'],
      name: data['client.Nome Completo'],
    )) {
      await showLocalProfileConflictDialog(context);
      return;
    }
    final hasSavedTutor =
        VetRepository.clientName.trim().isNotEmpty &&
        RegExp(
          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
        ).hasMatch(VetRepository.clientEmail.trim());
    if (!hasSavedTutor && !hasCompleteTutorRegistrationData(data)) {
      Navigator.pushReplacementNamed(
        context,
        '/cadastro',
        arguments: CadastroEntry.fromAddress,
      );
      return;
    }
    // O cadastro feito na etapa anterior já criou o cliente no backend e
    // preencheu a sessão. O endereço recebe o CPF da sessão automaticamente.
    if (Session.isLoggedIn &&
        (data['client.CEP']?.trim().isNotEmpty ?? false) &&
        (data['client.Endereço']?.trim().isNotEmpty ?? false)) {
      await EnderecoService.salvar(
        SavedAddress(
          id: 'address-${DateTime.now().microsecondsSinceEpoch}',
          street: data['client.Endereço']!.trim(),
          number: data['client.Número']?.trim() ?? '',
          complement: data['client.Complemento']?.trim() ?? '',
          city: data['client.Cidade']?.trim() ?? '',
          cep: data['client.CEP']!.trim(),
          neighborhood: data['client.Bairro']?.trim() ?? '',
        ),
      );
    }

    VetRepository.registerClient(data);
    final saved = await VetRepository.flush();
    if (!context.mounted || ModalRoute.isCurrentOf(context) != true) return;
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
    final nextData = <String, String>{
      if (saved)
        for (final entry in data.entries)
          if (!entry.key.startsWith('client.')) entry.key: entry.value,
      if (!saved) ...data,
      '_registrationSaved': saved.toString(),
    };
    Navigator.pushNamed(context, '/cadastroPet', arguments: nextData);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
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
        onSaved: (address) async {
          final data = withoutRegistrationPasswords({
            ...initialData,
            'client.CEP': address.cep,
            'client.Endereço': address.street,
            'client.Cidade': address.city,
            'client.Bairro': address.neighborhood,
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
