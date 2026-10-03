import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/vet_repository.dart';
import 'models/pet_model.dart';
import 'pages/agendamentos_page.dart';
import 'pages/detalhes_pet_page.dart';
import 'pages/editar_pet_page.dart';
import 'pages/login_page.dart';
import 'pages/perfil_page.dart';
import 'pages/pets_page.dart';
import 'pages/saude_page.dart';
import 'pages/vacinacao_page.dart';
import 'pages/nova_consulta_page.dart';
import 'screens/auth.dart';
import 'screens/outros.dart';
import 'screens/pets.dart'
    show ConvenioScreen, EscolhaPetScreen, ServicosScreen;
import 'theme.dart';

void main() {
  runApp(const VetHomeApp());
}

Map<String, String> _formDataFromRoute(BuildContext context) {
  final arguments = ModalRoute.of(context)?.settings.arguments;
  if (arguments is! Map) return const {};
  return arguments.map<String, String>(
    (key, value) => MapEntry(key.toString(), value.toString()),
  );
}

PetModel? _petFromRoute(BuildContext context) {
  final arguments = ModalRoute.of(context)?.settings.arguments;
  if (arguments is PetModel) return VetRepository.petById(arguments.id);

  final args = arguments is Map ? arguments : const <String, dynamic>{};
  final name = args['petName'];
  final id = args['petId'];
  if (id is String) return VetRepository.petById(id);
  // Compatibilidade de entrada com argumentos antigos, sem criar outro pet.
  if (name is String) {
    return VetRepository.pets.where((pet) => pet.name == name).firstOrNull;
  }
  return VetRepository.selectedPet;
}

Widget _petPage(BuildContext context, Widget Function(PetModel) builder) {
  final pet = _petFromRoute(context);
  return pet == null ? const PetsPage() : builder(pet);
}

class VetHomeApp extends StatelessWidget {
  const VetHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: VH.themeSeed,
      builder: (context, themeSeed, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Vet Home',
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: VetTheme.light(themeSeed),
        initialRoute: '/',
        routes: {
          '/': (_) => const SplashScreen(),
          '/login': (_) => const LoginPage(),
          '/cadastro': (_) => const CadastroScreen(),
          '/endereco': (context) =>
              EnderecoScreen(initialData: _formDataFromRoute(context)),
          '/cadastroPet': (context) =>
              CadastroPetScreen(initialData: _formDataFromRoute(context)),
          '/sucesso': (_) => const SucessoScreen(),
          '/pets': (_) => const PetsPage(),
          '/pet': (context) =>
              _petPage(context, (pet) => DetalhesPetPage(pet: pet)),
          '/editPet': (context) =>
              _petPage(context, (pet) => EditarPetPage(pet: pet)),
          '/escolhaPet': (_) => const EscolhaPetScreen(),
          '/servicos': (_) => const ServicosScreen(),
          '/convenio': (_) => const ConvenioScreen(),
          '/perfil': (_) => const PerfilPage(),
          '/chat': (_) => const ChatScreen(),
          '/sobre': (_) => const SobreScreen(),
          '/agenda': (_) => const AgendaScreen(),
          '/detalhes-pet': (context) =>
              _petPage(context, (pet) => DetalhesPetPage(pet: pet)),
          '/saude': (context) =>
              _petPage(context, (pet) => SaudePage(pet: pet)),
          '/vacinacao': (context) =>
              _petPage(context, (pet) => VacinacaoPage(pet: pet)),
          '/agendamentos': (context) =>
              _petPage(context, (pet) => AgendamentosPage(pet: pet)),
          '/nova-consulta': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            final values = args is Map ? args : const <String, dynamic>{};
            final pet = values['pet'] is PetModel
                ? VetRepository.petById((values['pet'] as PetModel).id)
                : VetRepository.selectedPet;
            if (pet == null) return const PetsPage();
            final service = values['service'];
            final plan = values['plan'];
            return NovaConsultaPage(
              pet: pet,
              service: service is String ? service : 'Consulta Geral',
              plan: plan is String ? plan : 'Particular',
            );
          },
          '/config': (_) => const ConfigScreen(),
        },
      ),
    );
  }
}
