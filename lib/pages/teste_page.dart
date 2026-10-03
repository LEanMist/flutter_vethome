import 'package:flutter/material.dart';

import '../data/vet_repository.dart';
import '../models/pet_model.dart';
import '../pages/agendamentos_page.dart';
import '../pages/detalhes_pet_page.dart';
import '../pages/editar_pet_page.dart';
import '../pages/login_page.dart';
import '../pages/nova_consulta_page.dart';
import '../pages/perfil_page.dart';
import '../pages/pets_page.dart';
import '../pages/saude_page.dart';
import '../pages/vacinacao_page.dart';
import '../screens/auth.dart'
    show CadastroPetScreen, CadastroScreen, EnderecoScreen, SucessoScreen;
import '../screens/outros.dart'
    show AgendaScreen, ChatScreen, ConfigScreen, SobreScreen;
import '../screens/pets.dart'
    show ConvenioScreen, EscolhaPetScreen, ServicosScreen;

class TestePage extends StatelessWidget {
  const TestePage({super.key});

  Widget _withSelectedPet(Widget Function(PetModel) builder) {
    final pet = VetRepository.selectedPet;
    return pet == null ? const PetsPage() : builder(pet);
  }

  @override
  Widget build(BuildContext context) {
    final telas = <({String titulo, IconData icone, WidgetBuilder pagina})>[
      (titulo: 'Login', icone: Icons.login, pagina: (_) => const LoginPage()),
      (
        titulo: 'Cadastro',
        icone: Icons.person_add_alt_1,
        pagina: (_) => const CadastroScreen(),
      ),
      (
        titulo: 'Endereço',
        icone: Icons.location_on_outlined,
        pagina: (_) => const EnderecoScreen(),
      ),
      (
        titulo: 'Cadastro de pet',
        icone: Icons.add_circle_outline,
        pagina: (_) => const CadastroPetScreen(),
      ),
      (
        titulo: 'Sucesso no cadastro',
        icone: Icons.check_circle_outline,
        pagina: (_) => const SucessoScreen(),
      ),
      (titulo: 'Pets', icone: Icons.pets, pagina: (_) => const PetsPage()),
      (
        titulo: 'Detalhes do pet',
        icone: Icons.info_outline,
        pagina: (_) => _withSelectedPet((pet) => DetalhesPetPage(pet: pet)),
      ),
      (
        titulo: 'Editar pet',
        icone: Icons.edit_outlined,
        pagina: (_) => _withSelectedPet((pet) => EditarPetPage(pet: pet)),
      ),
      (
        titulo: 'Escolha de pet',
        icone: Icons.pets_outlined,
        pagina: (_) => const EscolhaPetScreen(),
      ),
      (
        titulo: 'Serviços',
        icone: Icons.medical_services_outlined,
        pagina: (_) => const ServicosScreen(),
      ),
      (
        titulo: 'Convênio',
        icone: Icons.health_and_safety_outlined,
        pagina: (_) => const ConvenioScreen(),
      ),
      (
        titulo: 'Perfil',
        icone: Icons.person_outline,
        pagina: (_) => const PerfilPage(),
      ),
      (
        titulo: 'Chat',
        icone: Icons.chat_bubble_outline,
        pagina: (_) => const ChatScreen(),
      ),
      (
        titulo: 'Sobre',
        icone: Icons.info_outline,
        pagina: (_) => const SobreScreen(),
      ),
      (
        titulo: 'Agenda',
        icone: Icons.calendar_month_outlined,
        pagina: (_) => const AgendaScreen(),
      ),
      (
        titulo: 'Saúde do pet',
        icone: Icons.favorite_border,
        pagina: (_) => _withSelectedPet((pet) => SaudePage(pet: pet)),
      ),
      (
        titulo: 'Vacinação',
        icone: Icons.vaccines_outlined,
        pagina: (_) => _withSelectedPet((pet) => VacinacaoPage(pet: pet)),
      ),
      (
        titulo: 'Agendamentos',
        icone: Icons.event_note_outlined,
        pagina: (_) => _withSelectedPet((pet) => AgendamentosPage(pet: pet)),
      ),
      (
        titulo: 'Nova consulta',
        icone: Icons.add_task,
        pagina: (_) => _withSelectedPet(
          (pet) => NovaConsultaPage(
            pet: pet,
            service: 'Consulta Geral',
            plan: 'Particular',
          ),
        ),
      ),
      (
        titulo: 'Configurações',
        icone: Icons.settings_outlined,
        pagina: (_) => const ConfigScreen(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Telas do projeto')),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: telas.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final tela = telas[index];
          return SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: tela.pagina),
                );
              },
              icon: Icon(tela.icone),
              label: Text(tela.titulo),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          );
        },
      ),
    );
  }
}
