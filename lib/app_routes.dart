import 'package:flutter/material.dart';

import 'pages/Informacoes_page.dart';
import 'pages/agendamentos_page.dart';
import 'pages/despesas_page.dart';
import 'pages/detalhes_pet_page.dart';
import 'pages/login_page.dart';
import 'pages/menuPet_page.dart';
import 'pages/perfil_page.dart';
import 'pages/pets_page.dart';
import 'pages/saude_page.dart';
import 'pages/vacinacao_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String menu = '/menu';
  static const String pets = '/pets';
  static const String perfil = '/perfil';
  static const String informacoes = '/informacoes';
  static const String detalhesPet = '/detalhes-pet';
  static const String saude = '/saude';
  static const String vacinacao = '/vacinacao';
  static const String agendamentos = '/agendamentos';
  static const String despesas = '/despesas';

  static const String petsListScreen = '/pets_list_screen';
  static const String appNavigationScreen = '/app_navigation_screen';
  static const String initialRoute = '/';

  static Map<String, WidgetBuilder> get routes => {
    login: (_) => const LoginPage(),
    menu: (_) => const MenuPetPage(),
    pets: (_) => const PetsPage(),
    perfil: (_) => const PerfilPage(),
    informacoes: (_) => const InformacoesPage(),
    detalhesPet: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
          const <String, dynamic>{};
      return DetalhesPetPage(
        petName: args['petName'] as String? ?? 'Pet',
        petImage: args['petImage'] as String? ?? 'assets/imagens/pets/dog.png',
      );
    },
    saude: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
          const <String, dynamic>{};
      return SaudePage(
        petName: args['petName'] as String? ?? 'Pet',
        petImage: args['petImage'] as String? ?? 'assets/imagens/pets/dog.png',
      );
    },
    vacinacao: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
          const <String, dynamic>{};
      return VacinacaoPage(
        petName: args['petName'] as String? ?? 'Pet',
        petImage: args['petImage'] as String? ?? 'assets/imagens/pets/dog.png',
      );
    },
    agendamentos: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
          const <String, dynamic>{};
      return AgendamentosPage(
        petName: args['petName'] as String? ?? 'Pet',
        petImage: args['petImage'] as String? ?? 'assets/imagens/pets/dog.png',
      );
    },
    despesas: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
          const <String, dynamic>{};
      return DespesasPage(
        petName: args['petName'] as String? ?? 'Pet',
        petImage: args['petImage'] as String? ?? 'assets/imagens/pets/dog.png',
      );
    },
    petsListScreen: (_) => const PetsPage(),
    appNavigationScreen: (_) => const PetsPage(),
    initialRoute: (_) => const LoginPage(),
  };

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return _buildRoute(const LoginPage());
      case menu:
        return _buildRoute(const MenuPetPage());
      case pets:
        return _buildRoute(const PetsPage());
      case perfil:
        return _buildRoute(const PerfilPage());
      case informacoes:
        return _buildRoute(const InformacoesPage());
      case detalhesPet:
        final args =
            settings.arguments as Map<String, dynamic>? ??
            const <String, dynamic>{};
        return _buildRoute(
          DetalhesPetPage(
            petName: args['petName'] as String? ?? 'Pet',
            petImage:
                args['petImage'] as String? ?? 'assets/imagens/pets/dog.png',
          ),
        );
      case saude:
        final args =
            settings.arguments as Map<String, dynamic>? ??
            const <String, dynamic>{};
        return _buildRoute(
          SaudePage(
            petName: args['petName'] as String? ?? 'Pet',
            petImage:
                args['petImage'] as String? ?? 'assets/imagens/pets/dog.png',
          ),
        );
      case vacinacao:
        final args =
            settings.arguments as Map<String, dynamic>? ??
            const <String, dynamic>{};
        return _buildRoute(
          VacinacaoPage(
            petName: args['petName'] as String? ?? 'Pet',
            petImage:
                args['petImage'] as String? ?? 'assets/imagens/pets/dog.png',
          ),
        );
      case agendamentos:
        final args =
            settings.arguments as Map<String, dynamic>? ??
            const <String, dynamic>{};
        return _buildRoute(
          AgendamentosPage(
            petName: args['petName'] as String? ?? 'Pet',
            petImage:
                args['petImage'] as String? ?? 'assets/imagens/pets/dog.png',
          ),
        );
      case despesas:
        final args =
            settings.arguments as Map<String, dynamic>? ??
            const <String, dynamic>{};
        return _buildRoute(
          DespesasPage(
            petName: args['petName'] as String? ?? 'Pet',
            petImage:
                args['petImage'] as String? ?? 'assets/imagens/pets/dog.png',
          ),
        );
      case petsListScreen:
      case appNavigationScreen:
      case initialRoute:
        return _buildRoute(const PetsPage());
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
  static Future<void> toMenu() => _pushAndRemoveUntil(AppRoutes.menu);
  static Future<void> toPets() => _push(AppRoutes.pets);
  static Future<void> toPerfil() => _push(AppRoutes.perfil);
  static Future<void> toInformacoes() => _push(AppRoutes.informacoes);

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

  static Future<void> toDespesas({required String petName, String? petImage}) =>
      _push(
        AppRoutes.despesas,
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

  static Future<void> _pushAndRemoveUntil(String route, {Object? arguments}) {
    return navigatorKey.currentState?.pushNamedAndRemoveUntil(
          route,
          (route) => false,
          arguments: arguments,
        ) ??
        Future.value();
  }
}
