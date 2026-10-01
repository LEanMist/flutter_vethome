import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'pages/login_page.dart';
import 'screens/auth.dart';
import 'screens/outros.dart';
import 'screens/pets.dart';
import 'theme.dart';

void main() {
  runApp(const VetHomeApp());
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
        '/endereco': (_) => const EnderecoScreen(),
        '/cadastroPet': (_) => const CadastroPetScreen(),
        '/sucesso': (_) => const SucessoScreen(),
        '/pets': (_) => const PetsScreen(),
        '/pet': (_) => const PetScreen(),
        '/editPet': (_) => const EditPetScreen(),
        '/escolhaPet': (_) => const EscolhaPetScreen(),
        '/servicos': (_) => const ServicosScreen(),
        '/convenio': (_) => const ConvenioScreen(),
        '/perfil': (_) => const PerfilScreen(),
        '/chat': (_) => const ChatScreen(),
        '/sobre': (_) => const SobreScreen(),
        '/agenda': (_) => const AgendaScreen(),
        '/config': (_) => const ConfigScreen(),
      },
    );
  }
}
