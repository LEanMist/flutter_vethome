import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

PetModel _petFromRoute(BuildContext context) {
  final arguments = ModalRoute.of(context)?.settings.arguments;
  if (arguments is PetModel) return arguments;

  final args = arguments is Map ? arguments : const <String, dynamic>{};
  final name = args['petName'];
  final image = args['petImage'];
  final description = args['description'];

  return PetModel(
    name: name is String ? name : VetRepository.pets.first.name,
    imagePath: image is String ? image : VetRepository.pets.first.imagePath,
    description: description is String ? description : '',
  );
}

class VetHomeApp extends StatelessWidget {
  const VetHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vet Home',
      theme: ThemeData(
        scaffoldBackgroundColor: VH.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: VH.secondary,
          primary: VH.primary,
        ),
        textTheme: GoogleFonts.comfortaaTextTheme().apply(
          bodyColor: VH.foreground,
          displayColor: VH.foreground,
        ),
        useMaterial3: true,
      ),
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
        '/pet': (context) => DetalhesPetPage(pet: _petFromRoute(context)),
        '/editPet': (context) => EditarPetPage(pet: _petFromRoute(context)),
        '/escolhaPet': (_) => const EscolhaPetScreen(),
        '/servicos': (_) => const ServicosScreen(),
        '/convenio': (_) => const ConvenioScreen(),
        '/perfil': (_) => const PerfilPage(),
        '/chat': (_) => const ChatScreen(),
        '/sobre': (_) => const SobreScreen(),
        '/agenda': (_) => const AgendaScreen(),
        '/detalhes-pet': (context) =>
            DetalhesPetPage(pet: _petFromRoute(context)),
        '/saude': (context) => SaudePage(pet: _petFromRoute(context)),
        '/vacinacao': (context) => VacinacaoPage(pet: _petFromRoute(context)),
        '/agendamentos': (context) =>
            AgendamentosPage(pet: _petFromRoute(context)),
        '/nova-consulta': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final values = args is Map ? args : const <String, dynamic>{};
          final pet = values['pet'] is PetModel
              ? values['pet'] as PetModel
              : VetRepository.pets.first;
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
    );
  }
}
