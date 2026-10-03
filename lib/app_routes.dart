import 'package:flutter/material.dart';

import 'models/pet_model.dart';
import 'pages/agendamentos_page.dart';
import 'pages/detalhes_pet_page.dart';
import 'pages/login_page.dart';
import 'pages/perfil_page.dart';
import 'pages/pets_page.dart';
import 'pages/saude_page.dart';
import 'pages/vacinacao_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String pets = '/pets';
  static const String perfil = '/perfil';
  static const String detalhesPet = '/detalhes-pet';
  static const String saude = '/saude';
  static const String vacinacao = '/vacinacao';
  static const String agendamentos = '/agendamentos';

  static PetModel _petFromArguments(Object? arguments) {
    if (arguments is PetModel) return arguments;

    final args = arguments is Map ? arguments : const <String, dynamic>{};
    return PetModel(
      name: args['petName'] as String? ?? 'Pet',
      imagePath:
          args['petImage'] as String? ?? 'assets/imagens/pets/dog.png',
      description: args['description'] as String? ?? '',
    );
  }

  static Map<String, WidgetBuilder> get routes => {
    login: (_) => const LoginPage(),
    pets: (_) => const PetsPage(),
    perfil: (_) => const PerfilPage(),
    detalhesPet: (context) {
      final pet = _petFromArguments(
        ModalRoute.of(context)?.settings.arguments,
      );
      return DetalhesPetPage(pet: pet);
    },
    saude: (context) {
      final pet = _petFromArguments(
        ModalRoute.of(context)?.settings.arguments,
      );
      return SaudePage(pet: pet);
    },
    vacinacao: (context) {
      final pet = _petFromArguments(
        ModalRoute.of(context)?.settings.arguments,
      );
      return VacinacaoPage(pet: pet);
    },
    agendamentos: (context) {
      final pet = _petFromArguments(
        ModalRoute.of(context)?.settings.arguments,
      );
      return AgendamentosPage(pet: pet);
    },
  };

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return _buildRoute(const LoginPage());
      case pets:
        return _buildRoute(const PetsPage());
      case perfil:
        return _buildRoute(const PerfilPage());
      case detalhesPet:
        return _buildRoute(
          DetalhesPetPage(pet: _petFromArguments(settings.arguments)),
        );
      case saude:
        return _buildRoute(
          SaudePage(pet: _petFromArguments(settings.arguments)),
        );
      case vacinacao:
        return _buildRoute(
          VacinacaoPage(pet: _petFromArguments(settings.arguments)),
        );
      case agendamentos:
        return _buildRoute(
          AgendamentosPage(pet: _petFromArguments(settings.arguments)),
        );
      default:
        return _buildRoute(_notFoundScreen());
    }
  }

  static Widget _notFoundScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('Rota não encontrada'),
          ],
        ),
      ),
    );
  }

  static Route<dynamic> _buildRoute(Widget page) {
    return MaterialPageRoute(builder: (_) => page);
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class Nav {
  static Future<void> toLogin() => _push(AppRoutes.login);
  static Future<void> toPets() => _push(AppRoutes.pets);
  static Future<void> toPerfil() => _push(AppRoutes.perfil);

  static Future<void> toDetalhesPet({
    required String petName,
    String? petImage,
  }) => _push(
    AppRoutes.detalhesPet,
    arguments: {
      'petName': petName,
      'petImage': petImage ?? 'assets/imagens/pets/dog.png',
    },
  );

  static Future<void> toSaude({required String petName, String? petImage}) =>
      _push(
        AppRoutes.saude,
        arguments: {
          'petName': petName,
          'petImage': petImage ?? 'assets/imagens/pets/dog.png',
        },
      );

  static Future<void> toVacinacao({
    required String petName,
    String? petImage,
  }) => _push(
    AppRoutes.vacinacao,
    arguments: {
      'petName': petName,
      'petImage': petImage ?? 'assets/imagens/pets/dog.png',
    },
  );

  static Future<void> toAgendamentos({
    required String petName,
    String? petImage,
  }) => _push(
    AppRoutes.agendamentos,
    arguments: {
      'petName': petName,
      'petImage': petImage ?? 'assets/imagens/pets/dog.png',
    },
  );

  static void pop() {
    if (navigatorKey.currentState?.canPop() ?? false) {
      navigatorKey.currentState?.pop();
    }
  }

  static Future<void> _push(String route, {Object? arguments}) {
    return navigatorKey.currentState?.pushNamed(route, arguments: arguments) ??
        Future.value();
  }

}
