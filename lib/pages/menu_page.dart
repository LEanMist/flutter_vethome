import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_vethome/models/pet.dart';
import 'package:flutter_vethome/repositories/pet_repository.dart';
import 'package:flutter_vethome/widgets/pet_card.dart';
import 'agendamento_page.dart';
import 'contato_page.dart';
import 'configuracoes_page.dart';
import 'perfil_page.dart';
import 'cadastro_pet_page.dart';
import '../widgets/circulo_clicavel.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPage();
}

class _MenuPage extends State<MenuPage> {
  final repository = InMemoryPetRepository.instance;
  late final List<Pet> _pets;
  int indiceAtual = 0;

  @override
  void initState() {
    super.initState();
    _pets = repository.findAll();
  }

  void cadastropet() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CadastroPetPage(
          destinoBuilder: (context) => const MenuPage(),
        ),
      ),
    ).then((_) => {
      if (mounted) {
        setState(() => _pets = repository.findAll())
      }
    });
  }

  final List<Widget> telas = const [
    PerfilPage(),
    ContatoPage(),
    AgendamentoPage(),
    ConfiguracoesPage(),
  ];

  Widget _buildPetsPage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool compacto =
            constraints.maxWidth < 500 || constraints.maxHeight < 700;
        final double alturaCabecalho = compacto ? 140 : 160;
        final double alturaCampoAnimais = compacto ? 480 : 700;
        final double larguraCampoAnimais = compacto ? 350 : 180;
        final double alturaBotao = compacto ? 50 : 60;
        final double larguraBotao = compacto ? 120 : 250;

        return Column(
          children: [
            Container(
              width: double.infinity,
              height: alturaCabecalho,
              decoration: BoxDecoration(
                color: const Color(0xFFC08081),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(top: 30),
              child: Text(
                'Pets',
                style: GoogleFonts.comfortaa(
                  color: Color(0xFFFFFFFF),
                  fontSize: compacto ? 30 : 35,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 60),
            Container(
              width: larguraCampoAnimais,
              height: alturaCampoAnimais,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(192, 128, 129, 0.25),
                borderRadius: BorderRadius.circular(35),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _pets.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhum pet cadastrado ainda.',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: _pets.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return PetCard(
                            pet: _pets[index],
                            onDetails: () => ScaffoldMessenger.of(context)
                                .showSnackBar(
                                  const SnackBar(
                                    content: Text('Detalhes do pet em breve.'),
                                  ),
                                ),
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: cadastropet,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(larguraBotao, alturaBotao),
                backgroundColor: const Color(0xFF68442E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(35),
                ),
                padding: EdgeInsets.zero,
              ),
              child: const Tooltip(
                message: 'Adicionar pet',
                child: Icon(Icons.add, size: 40, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNavigationBar() {
    const icones = [
      Icons.pets,
      Icons.person,
      Icons.call,
      Icons.calendar_month,
      Icons.settings,
    ];
    const rotulos = [
      'Pets',
      'Perfil',
      'Contato',
      'Agendamentos',
      'Configurações',
    ];

    return SafeArea(
      top: false,
      child: Container(
        height: 75,
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 17),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFD9A4A5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(icones.length, (index) {
            return CirculoClicavel(
              icone: icones[index],
              tooltip: rotulos[index],
              selecionado: indiceAtual == index,
              onPressed: () => setState(() => indiceAtual = index),
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAD3D5),
      body: IndexedStack(
        index: indiceAtual,
        children: [_buildPetsPage(), ...telas],
      ),
      bottomNavigationBar: _buildNavigationBar(),
    );
  }
}