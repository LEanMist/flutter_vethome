import 'package:flutter/material.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset;
import 'package:flutter_vethome/models/agendamento.dart';
import 'package:flutter_vethome/repositories/agendamento_repository.dart';
import 'package:flutter_vethome/repositories/pet_repository.dart';
import 'package:flutter_vethome/repositories/usuario_repository.dart';
import 'package:flutter_vethome/themes/vet_cores.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoricoAgendamentoPage extends StatefulWidget {
  const HistoricoAgendamentoPage({
    super.key,
    this.usuarioId,
    this.usuarioRepository,
    this.agendamentoRepository,
    this.petRepository,
  });

  final String? usuarioId;
  final UsuarioRepository? usuarioRepository;
  final AgendamentoRepository? agendamentoRepository;
  final PetRepository? petRepository;

  @override
  State<HistoricoAgendamentoPage> createState() =>
      _HistoricoAgendamentoPageState();
}

class _HistoricoAgendamentoPageState extends State<HistoricoAgendamentoPage> {
  late final Future<List<_ItemHistorico>> _historico = _carregarHistorico();

  Future<List<_ItemHistorico>> _carregarHistorico() async {
    final usuarios =
        widget.usuarioRepository ?? InMemoryUsuarioRepository.instance;
    final disponiveis = usuarios.findAll();
    final id =
        widget.usuarioId ?? (disponiveis.isEmpty ? null : disponiveis.first.id);
    if (id == null || usuarios.findById(id) == null) {
      throw StateError('Não foi possível carregar os dados do usuário.');
    }
    final repository =
        widget.agendamentoRepository ?? InMemoryAgendamentoRepository.instance;
    final pets = widget.petRepository ?? InMemoryPetRepository.instance;
    final agendamentos = await repository.findByUsuarioId(id);
    final nomesPets = {
      for (final pet in pets.findByUsuarioId(id)) pet.id: pet.nome,
    };
    return [
      for (final agendamento in agendamentos.reversed)
        _ItemHistorico(
          agendamento: agendamento,
          pet: nomesPets[agendamento.petId] ?? 'Pet não encontrado',
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VetCores.rosaFundo,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compacto =
                constraints.maxWidth < 500 || constraints.maxHeight < 700;
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  height: compacto ? 120 : 160,
                  decoration: const BoxDecoration(
                    color: VetCores.rosaEscuro,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 56),
                        child: Text(
                          'Histórico',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.comfortaa(
                            color: VetCores.branco,
                            fontSize: compacto ? 30 : 35,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 8,
                        child: IconButton(
                          tooltip: 'Voltar',
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                          color: VetCores.branco,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: compacto ? 10 : 24),
                Expanded(
                  child: FutureBuilder<List<_ItemHistorico>>(
                    future: _historico,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: VetCores.marrom,
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return _mensagem(
                          'Não foi possível carregar o histórico de agendamentos.',
                        );
                      }
                      final historico = snapshot.requireData;
                      if (historico.isEmpty) {
                        return _mensagem('Nenhum agendamento encontrado.');
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: historico.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 14),
                        itemBuilder: (context, index) =>
                            _cartao(historico[index], compacto),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _mensagem(String texto) => Center(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: GoogleFonts.comfortaa(color: VetCores.marrom),
      ),
    ),
  );

  Widget _cartao(_ItemHistorico item, bool compacto) {
    final agendamento = item.agendamento;
    final data = agendamento.data;
    final dataFormatada =
        '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/${data.year}';
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: compacto ? 170 : 250),
          padding: const EdgeInsets.all(20),
          decoration: inset.BoxDecoration(
            color: VetCores.rosaEscuro50,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              inset.BoxShadow(
                color: Color.fromARGB(55, 0, 0, 0),
                blurRadius: 2,
                offset: Offset(3, 3),
                inset: true,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _linha('Data:', dataFormatada),
              _linha('Horário:', agendamento.horario),
              _linha('Pet:', item.pet),
              _linha(
                'Serviços:',
                agendamento.servicos.map((s) => s.nome).join(', '),
              ),
              _linha(
                'Endereço:',
                agendamento.endereco.trim().isEmpty
                    ? 'Endereço não informado'
                    : agendamento.endereco,
                ultima: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _linha(String titulo, String valor, {bool ultima = false}) => Padding(
    padding: EdgeInsets.only(bottom: ultima ? 0 : 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            titulo,
            style: GoogleFonts.comfortaa(
              color: VetCores.marrom,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Text(
            valor,
            style: GoogleFonts.comfortaa(
              color: VetCores.marrom,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}

class _ItemHistorico {
  const _ItemHistorico({required this.agendamento, required this.pet});

  final Agendamento agendamento;
  final String pet;
}
