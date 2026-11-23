import 'dart:async';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/material.dart';

import '../auth/auth_session.dart';
import '../auth/authentication.dart';
import '../data/vet_repository.dart';
import '../pages/addresses_page.dart';
import '../pages/agenda_page.dart';
import '../pages/chat_page.dart';
import '../pages/config_page.dart';
import '../pages/gabriela/gabriela_area_page.dart';
import '../models/saved_address.dart';
import '../models/pet_model.dart';
import '../pages/agendamentos_page.dart';
import '../pages/detalhes_pet_page.dart';
import '../pages/editar_pet_page.dart';
import '../pages/login_page.dart';
import '../pages/perfil_page.dart';
import '../pages/pets_page.dart';
import '../pages/saude_page.dart';
import '../pages/sobre_page.dart';
import '../pages/splashScreen.dart';
import '../pages/sucessoScreen.dart';
import '../pages/vacinacao_page.dart';
import '../pages/nova_consulta_page.dart';
import '../pages/cadastro_page.dart';
import '../pages/endereco_page.dart';
import '../pages/cadastroPet_page.dart';
import '../screens/pets.dart'
    show ConvenioScreen, EscolhaPetScreen, ServicosScreen, openPetChoiceDialog;

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

class AppRoutes {
  AppRoutes(this.session);

  final AuthSession session;

  Route<dynamic>? generate(RouteSettings requested) {
    final path = switch (requested.name) {
      '/gabriela/splash' => '/',
      '/gabriela/login' => '/login',
      '/home' => '/pets',
      final name => name,
    };
    if (path == null || !_pages.containsKey(path)) return null;
    final destination = _authorizedDestination(path, requested.arguments);
    return MaterialPageRoute<dynamic>(
      settings: RouteSettings(
        name: destination,
        arguments: destination == path ? requested.arguments : null,
      ),
      builder: _pages[destination]!,
    );
  }

  List<Route<dynamic>> initialRoutes(String name) => [
    generate(RouteSettings(name: name)) ??
        generate(const RouteSettings(name: '/login'))!,
  ];

  String _authorizedDestination(String path, Object? arguments) {
    final home = session.homeRoute;
    if (path == '/' || path == '/login') return home ?? path;

    final role = session.user?.role;
    if (path == '/gabriela' || path.startsWith('/gabriela/')) {
      return role == UserRole.veterinaria ? path : home ?? '/login';
    }
    if (role == UserRole.cliente) return path;

    final demoRegistration =
        session.isDemo &&
        (path == '/cadastro' ||
            (path == '/endereco' || path == '/cadastroPet') &&
                arguments is Map ||
            path == '/sucesso' && arguments is bool);
    return role == null && demoRegistration ? path : home ?? '/login';
  }

  @visibleForTesting
  static Map<String, WidgetBuilder> get routes => {
    ..._pages,
    '/home': _pages['/pets']!,
  };

  static final _pages = <String, WidgetBuilder>{
    '/': (_) => const SplashScreen(),
    '/login': (_) => const LoginPage(),
    '/gabriela': (_) => const GabrielaAreaPage(),
    '/gabriela/perfil': (_) => const GabrielaAreaPage(initialIndex: 0),
    '/gabriela/mensagens': (_) => const GabrielaAreaPage(initialIndex: 1),
    '/gabriela/agenda': (_) => const GabrielaAreaPage(initialIndex: 2),
    '/gabriela/configuracoes': (_) => const GabrielaAreaPage(initialIndex: 3),
    '/cadastro': (context) => CadastroScreen(
      entry: switch (ModalRoute.of(context)?.settings.arguments) {
        final CadastroEntry entry => entry,
        _ => null,
      },
    ),
    '/endereco': (context) =>
        EnderecoScreen(initialData: _formDataFromRoute(context)),
    '/cadastroPet': (context) =>
        CadastroPetScreen(initialData: _formDataFromRoute(context)),
    '/sucesso': (context) => SucessoScreen(
      saved: ModalRoute.of(context)?.settings.arguments == true,
    ),
    '/pets': (_) => const PetsPage(),
    '/pet': (context) => _petPage(context, (pet) => DetalhesPetPage(pet: pet)),
    '/editPet': (context) =>
        _petPage(context, (pet) => EditarPetPage(pet: pet)),
    '/escolhaPet': (_) => const _PetChoiceFlowRoute(),
    '/servicos': (_) => const ServicosScreen(),
    '/convenio': (_) => const ConvenioScreen(),
    '/perfil': (_) => const PerfilPage(),
    '/chat': (_) => const ChatScreen(),
    '/sobre': (_) => const SobreScreen(),
    '/agenda': (context) => AgendaScreen(
      initialDate: ModalRoute.of(context)?.settings.arguments is DateTime
          ? ModalRoute.of(context)!.settings.arguments as DateTime
          : null,
    ),
    '/saude': (context) => _petPage(context, (pet) => SaudePage(pet: pet)),
    '/vacinacao': (context) =>
        _petPage(context, (pet) => VacinacaoPage(pet: pet)),
    '/agendamentos': (context) =>
        _petPage(context, (pet) => AgendamentosPage(pet: pet)),
    '/nova-consulta': (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      final values = args is Map ? args : const <String, dynamic>{};
      final pet = values['petId'] is String
          ? VetRepository.petById(values['petId'] as String)
          : values['pet'] is PetModel
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
    '/enderecos': (_) => const AddressesPage(),
    '/editar-endereco': (context) => AddressEditorPage(
      address: ModalRoute.of(context)?.settings.arguments as SavedAddress?,
    ),
  };
}

/// A rota móvel mantém a Agenda ao fundo e abre o painel CHOICE_PET_WIDGET.
/// Em telas largas, a página original de seleção continua disponível.
class _PetChoiceFlowRoute extends StatefulWidget {
  const _PetChoiceFlowRoute();

  @override
  State<_PetChoiceFlowRoute> createState() => _PetChoiceFlowRouteState();
}

class _PetChoiceFlowRouteState extends State<_PetChoiceFlowRoute> {
  bool _dialogScheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.sizeOf(context).width >= 900 || _dialogScheduled) return;

    _dialogScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(openPetChoiceDialog(context));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width >= 900) {
      return const EscolhaPetScreen();
    }
    return AgendaScreen();
  }
}
