import 'package:flutter/material.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_vethome/models/pet.dart';
import 'package:flutter_vethome/repositories/pet_repository.dart';
import 'package:flutter_vethome/repositories/agendamento_repository.dart';
import 'package:flutter_vethome/repositories/usuario_repository.dart';
import 'package:flutter_vethome/widgets/pet_card.dart';
import 'agendamento_page.dart';
import 'contato_page.dart';
import 'configuracoes_page.dart';
import 'perfil_page.dart';
import 'pet_perfil_page.dart';
import 'cadastro_pet_page.dart';
import '../widgets/circulo_clicavel.dart';


class MenuPage extends StatefulWidget {
  const MenuPage({
    super.key,
    this.usuarioRepository,
    this.usuarioId,
    this.petRepository,
    this.agendamentoRepository,
  });

  final UsuarioRepository? usuarioRepository;
  final String? usuarioId;
  final PetRepository? petRepository;
  final AgendamentoRepository? agendamentoRepository;

  @override
  State<MenuPage> createState() => _MenuPage();
}

class _MenuPage extends State<MenuPage> {
  late final PetRepository repository;
  late final UsuarioRepository _usuarioRepository;
  late final String? _usuarioId;
  late final List<Widget> telas;
  late List<Pet> _pets;
  String? _petSelecionadoId;
  final _atualizacaoAgendamentos = ValueNotifier<int>(0);
  int indiceAtual = 0;

  @override
  void initState() {
    super.initState();
    repository = widget.petRepository ?? InMemoryPetRepository.instance;
    _usuarioRepository =
        widget.usuarioRepository ?? InMemoryUsuarioRepository.instance;
    final usuarios = _usuarioRepository.findAll();
    _usuarioId =
        widget.usuarioId ?? (usuarios.isEmpty ? null : usuarios.first.id);
    _pets = _petsDoUsuario();
    telas = [
      PerfilPage(
        usuarioRepository: _usuarioRepository,
        usuarioId: _usuarioId,
      ),
      ContatoPage(
        usuarioRepository: _usuarioRepository,
        usuarioId: _usuarioId,
      ),
      AgendamentoPage(
        usuarioRepository: _usuarioRepository,
        usuarioId: _usuarioId,
        petRepository: repository,
        agendamentoRepository: widget.agendamentoRepository,
        atualizacaoAgendamentos: _atualizacaoAgendamentos,
        onAgendamentoConcluido: () => _atualizacaoAgendamentos.value++,
      ),
      ConfiguracoesPage(
        usuarioRepository: _usuarioRepository,
        usuarioId: _usuarioId,
        petRepository: repository,
        agendamentoRepository: widget.agendamentoRepository,
      ),
    ];
  }

  @override
  void dispose() {
    _atualizacaoAgendamentos.dispose();
    super.dispose();
  }

  List<Pet> _petsDoUsuario() {
    final id = _usuarioId;
    return id == null ? [] : repository.findByUsuarioId(id);
  }

  void cadastropet() {
    final id = _usuarioId;
    if (id == null || _usuarioRepository.findById(id) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível identificar o usuário.')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CadastroPetPage(
          usuarioId: id,
          petRepository: repository,
          destinoBuilder: (context) => MenuPage(
            usuarioRepository: _usuarioRepository,
            usuarioId: _usuarioId,
            petRepository: repository,
            agendamentoRepository: widget.agendamentoRepository,
          ),
        ),
      ),
    ).then((_) => {
      if (mounted) {
        setState(() => _pets = _petsDoUsuario())
      }
    });
  }

  Widget _buildPetsPage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool compacto =
            constraints.maxWidth < 500 || constraints.maxHeight < 700;
        final double alturaCabecalho = compacto ? 120 : 160;
        final double alturaCampoAnimais = compacto ? 480 : 700;
        final double larguraCampoAnimais = compacto ? 370 : 180;
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
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final pet = _pets[index];
                          return PetCard(
                            pet: pet,
                            onDetails: () {
                              if (pet.id == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Não foi possível identificar o pet.'),
                                  ),
                                );
                                return;
                              }
                              setState(() => _petSelecionadoId = pet.id);
                            },
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
        decoration: inset.BoxDecoration(
          color: const Color(0xFFD9A4A5),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            inset.BoxShadow(
              color: Color.fromARGB(55, 70, 40, 41),
              blurRadius: 1,
              offset: Offset(2, 3),
              inset: true,
            ),
          ],
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
        children: [
          if (_petSelecionadoId == null)
            _buildPetsPage()
          else
            PetPerfilPage(
              key: ValueKey(_petSelecionadoId),
              petId: _petSelecionadoId!,
              usuarioId: _usuarioId!,
              petRepository: repository,
              usuarioRepository: _usuarioRepository,
              agendamentoRepository: widget.agendamentoRepository,
              atualizacaoAgendamentos: _atualizacaoAgendamentos,
              onAgendamentoConcluido: () => _atualizacaoAgendamentos.value++,
              onVoltar: () => setState(() {
                _petSelecionadoId = null;
                _pets = _petsDoUsuario();
              }),
            ),
          ...telas,
        ],
      ),
      bottomNavigationBar: _buildNavigationBar(),
    );
  }
}