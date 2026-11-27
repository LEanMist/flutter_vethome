import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_vethome/models/agendamento.dart';
import 'package:flutter_vethome/models/pet.dart';
import 'package:flutter_vethome/pages/detalhes_pet_page.dart';
import 'package:flutter_vethome/pages/servicos_page.dart';
import 'package:flutter_vethome/repositories/agendamento_repository.dart';
import 'package:flutter_vethome/repositories/pet_repository.dart';
import 'package:flutter_vethome/repositories/usuario_repository.dart';
import 'package:flutter_vethome/services/perfil_foto_service.dart';
import 'package:flutter_vethome/themes/vet_cores.dart';
import 'package:flutter_vethome/widgets/barra_rolagem.dart';
import 'package:flutter_vethome/widgets/botao_estilizado.dart';
import 'package:flutter_vethome/widgets/calendario.dart';
import 'package:flutter_vethome/widgets/etiqueta_perfil.dart';
import 'package:flutter_vethome/widgets/seletor_horario.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset;

class PetPerfilPage extends StatefulWidget {
  const PetPerfilPage({
    super.key,
    required this.petId,
    required this.usuarioId,
    required this.petRepository,
    required this.onVoltar,
    this.usuarioRepository,
    this.agendamentoRepository,
    this.onAgendamentoConcluido,
    this.atualizacaoAgendamentos,
  });

  final String petId;
  final String usuarioId;
  final PetRepository petRepository;
  final VoidCallback onVoltar;
  final UsuarioRepository? usuarioRepository;
  final AgendamentoRepository? agendamentoRepository;
  final VoidCallback? onAgendamentoConcluido;
  final Listenable? atualizacaoAgendamentos;

  @override
  State<PetPerfilPage> createState() => _PetPerfilPage();
}

class _PetPerfilPage extends State<PetPerfilPage> with WidgetsBindingObserver {
  static const _recuoAgendamentos = 48.0;
  final _scrollAgendamentos = ScrollController();
  bool _selecionandoFoto = false;
  bool _agendandoConsulta = false;
  bool _carregandoAgendamentos = true;
  bool _erroAgendamentos = false;
  bool _mostrarDetalhes = false;
  List<Agendamento> _agendamentosAtivos = [];
  Timer? _timerConclusao;
  int _versaoCarregamento = 0;

  AgendamentoRepository get _agendamentoRepository =>
      widget.agendamentoRepository ?? InMemoryAgendamentoRepository.instance;

  Pet? get _pet {
    final pet = widget.petRepository.findById(widget.petId);
    return pet?.usuarioId == widget.usuarioId ? pet : null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.atualizacaoAgendamentos?.addListener(_atualizarAgendamentos);
    unawaited(_carregarAgendamentos());
  }

  @override
  void didUpdateWidget(covariant PetPerfilPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.atualizacaoAgendamentos != widget.atualizacaoAgendamentos) {
      oldWidget.atualizacaoAgendamentos?.removeListener(_atualizarAgendamentos);
      widget.atualizacaoAgendamentos?.addListener(_atualizarAgendamentos);
    }
    if (oldWidget.petId != widget.petId ||
        oldWidget.usuarioId != widget.usuarioId ||
        oldWidget.petRepository != widget.petRepository ||
        oldWidget.agendamentoRepository != widget.agendamentoRepository) {
      _agendamentosAtivos = [];
      unawaited(_carregarAgendamentos());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _atualizarAgendamentos();
  }

  @override
  void dispose() {
    _timerConclusao?.cancel();
    _scrollAgendamentos.dispose();
    widget.atualizacaoAgendamentos?.removeListener(_atualizarAgendamentos);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _atualizarAgendamentos() => unawaited(_carregarAgendamentos());

  void _abrirDetalhes() {
    setState(() => _mostrarDetalhes = true);
  }

  Future<void> _carregarAgendamentos() async {
    final versao = ++_versaoCarregamento;
    _timerConclusao?.cancel();
    if (_pet == null) {
      setState(() {
        _agendamentosAtivos = [];
        _carregandoAgendamentos = false;
        _erroAgendamentos = false;
      });
      return;
    }
    setState(() {
      _carregandoAgendamentos = true;
      _erroAgendamentos = false;
    });
    try {
      final agendamentos = await _agendamentoRepository.findByPetId(
        widget.petId,
      );
      if (!mounted || versao != _versaoCarregamento) return;
      final ativos =
          agendamentos
              .where(
                (agendamento) =>
                    agendamento.petId == widget.petId &&
                    agendamento.usuarioId == widget.usuarioId &&
                    agendamento.status == StatusAgendamento.ativo,
              )
              .toList()
            ..sort((a, b) {
              final porData = a.data.compareTo(b.data);
              return porData != 0 ? porData : a.horario.compareTo(b.horario);
            });
      setState(() {
        _agendamentosAtivos = ativos;
        _carregandoAgendamentos = false;
      });
      if (ativos.isNotEmpty) {
        final restante = ativos.first.dataHoraConclusao.difference(
          DateTime.now(),
        );
        _timerConclusao = Timer(
          restante > Duration.zero ? restante : const Duration(minutes: 1),
          _atualizarAgendamentos,
        );
      }
    } catch (error) {
      if (!mounted || versao != _versaoCarregamento) return;
      setState(() {
        _agendamentosAtivos = [];
        _carregandoAgendamentos = false;
        _erroAgendamentos = true;
      });
    }
  }

  Future<void> _agendarConsulta() async {
    if (_agendandoConsulta) return;
    final usuarios =
        widget.usuarioRepository ?? InMemoryUsuarioRepository.instance;
    final agendamentos =
        widget.agendamentoRepository ?? InMemoryAgendamentoRepository.instance;
    if (usuarios.findById(widget.usuarioId) == null || _pet == null) {
      _mostrarMensagem('Não foi possível identificar o usuário ou o pet.');
      return;
    }

    _agendandoConsulta = true;
    try {
      final data = await selecionarDataAgendamento(
        context,
        dataInicial: DateUtils.dateOnly(DateTime.now()),
      );
      if (!mounted || data == null) return;
      final horario = await selecionarHorarioAgendamento(
        context,
        data: data,
        repository: agendamentos,
      );
      if (!mounted || horario == null) return;

      final pet = _pet;
      if (usuarios.findById(widget.usuarioId) == null || pet == null) {
        _mostrarMensagem('Não foi possível identificar o usuário ou o pet.');
        return;
      }
      if (!horariosDisponiveisAgendamento.contains(horario)) {
        _mostrarMensagem('Selecione um horário disponível.');
        return;
      }
      final rascunho = AgendamentoRascunho(
        usuarioId: widget.usuarioId,
        petId: widget.petId,
        data: data,
        horario: horario,
      );
      if (rascunho.errors.isNotEmpty) {
        _mostrarMensagem(rascunho.errors.first);
        return;
      }
      final agendamento = await Navigator.of(context).push<Agendamento>(
        MaterialPageRoute(
          builder: (_) => ServicosPage(
            rascunho: rascunho,
            petNome: pet.nome,
            petTipo: pet.tipo,
            petFotoPerfilPath: pet.fotoPerfilPath,
            usuarioRepository: usuarios,
            agendamentoRepository: agendamentos,
          ),
        ),
      );
      if (!mounted || agendamento == null) return;
      widget.onAgendamentoConcluido?.call();
      if (widget.onAgendamentoConcluido == null ||
          widget.atualizacaoAgendamentos == null) {
        _atualizarAgendamentos();
      }
      _mostrarMensagem('Agendamento concluído para ${pet.nome}.');
    } finally {
      _agendandoConsulta = false;
    }
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  Future<void> _selecionarFoto() async {
    if (_selecionandoFoto) return;
    _selecionandoFoto = true;
    try {
      final imagem = await selecionarFotoPerfil(context);
      if (imagem == null || !mounted) return;
      if (_pet == null) {
        throw StateError('Não foi possível encontrar o pet.');
      }
      final caminho = await armazenarFotoPet(imagem, widget.petId);
      if (!mounted) return;
      final pet = _pet;
      if (pet == null) {
        throw StateError('Não foi possível encontrar o pet.');
      }
      widget.petRepository.save(pet.copyWith(fotoPerfilPath: caminho));
      setState(() {});
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Não foi possível selecionar ou salvar a foto: $error',
            ),
          ),
        );
      }
    } finally {
      _selecionandoFoto = false;
    }
  }

  Widget _listaAgendamentos(double alturaMaximaCartao) {
    final estilo = GoogleFonts.montserratAlternates(
      color: VetCores.marrom,
      fontSize: 15,
      fontWeight: FontWeight.w500,
    );
    final alturaMaximaLista = math.max(0.0, alturaMaximaCartao - 32 - 32 - 8);
    final semAgendamentos =
        !_carregandoAgendamentos &&
        !_erroAgendamentos &&
        _agendamentosAtivos.isEmpty;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.calendar_month_rounded,
              size: 32,
              color: VetCores.marrom,
            ),
            const SizedBox(width: _recuoAgendamentos - 32),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Próximo Agendamento',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserratAlternates(
                      color: VetCores.marrom,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (semAgendamentos)
                    Text('Nenhum Agendamento Futuro', style: estilo)
                  else if (_erroAgendamentos)
                    Text(
                      'Não foi possível carregar os agendamentos.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: estilo.copyWith(fontSize: 13),
                    ),
                ],
              ),
            ),
            if (_carregandoAgendamentos)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: VetCores.marrom,
                ),
              )
            else if (_erroAgendamentos)
              IconButton(
                tooltip: 'Tentar novamente',
                onPressed: _atualizarAgendamentos,
                icon: const Icon(Icons.refresh_rounded),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints.tightFor(
                  width: 32,
                  height: 32,
                ),
              ),
          ],
        ),
        if (_agendamentosAtivos.isNotEmpty &&
            !_carregandoAgendamentos &&
            !_erroAgendamentos) ...[
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: alturaMaximaLista),
            child: BarraRolagem(
              controller: _scrollAgendamentos,
              child: ListView.separated(
                controller: _scrollAgendamentos,
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                key: const ValueKey('agendamentos-do-pet'),
                padding: EdgeInsets.zero,
                itemCount: _agendamentosAtivos.length,
                separatorBuilder: (_, _) =>
                    const Divider(color: VetCores.marrom25),
                itemBuilder: (context, index) =>
                    _itemAgendamento(_agendamentosAtivos[index], estilo),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _cartaoAgendamentos(double alturaMaxima) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: alturaMaxima),
      child: Container(
        key: const ValueKey('cartao-agendamentos-pet'),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: inset.BoxDecoration(
          color: VetCores.rosaEscuro25,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            inset.BoxShadow(
              color: Color.fromARGB(55, 0, 0, 0),
              blurRadius: 1,
              offset: Offset(3, 3),
              inset: true,
            ),
          ],
        ),
        child: _listaAgendamentos(alturaMaxima),
      ),
    );
  }

  Widget _itemAgendamento(Agendamento agendamento, TextStyle estilo) {
    final data = agendamento.data;
    final dataFormatada =
        '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/${data.year}';
    final servico = agendamento.servicos.isEmpty
        ? 'Serviço não informado'
        : agendamento.servicos.first.nome;
    return Padding(
      padding: const EdgeInsets.fromLTRB(_recuoAgendamentos, 4, 0, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$dataFormatada - ${agendamento.horario}', style: estilo),
          const SizedBox(height: 4),
          Text(servico, style: estilo),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pet = _pet;
    if (_mostrarDetalhes && pet != null) {
      return PopScope<Object?>(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) setState(() => _mostrarDetalhes = false);
        },
        child: DetalhesPetPage(
          pet: pet,
          usuarioId: widget.usuarioId,
          agendamentoRepository: _agendamentoRepository,
          petRepository: widget.petRepository,
          onVoltar: () => setState(() => _mostrarDetalhes = false),
          onPetAtualizado: () => setState(() {}),
          atualizacaoAgendamentos: widget.atualizacaoAgendamentos,
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final compacto =
            constraints.maxWidth < 500 || constraints.maxHeight < 700;
        final telaBaixa = constraints.maxHeight < 700;
        final alturaCabecalho = compacto ? 140.0 : 160.0;
        final alturaEtiqueta = compacto ? 290.0 : 350.0;
        final offsetEtiqueta = telaBaixa ? 20.0 : EtiquetaPerfil.offsetTop;
        final pet = _pet;
        final alturaBotaoConsulta = compacto ? 50.0 : 60.0;
        final larguraBotaoConsulta = compacto ? 150.0 : 250.0;
        const alturaBotoesPerfil = 52.0;
        final espacamento = telaBaixa ? 2.0 : (compacto ? 16.0 : 24.0);

        return Column(
          children: [
            SizedBox(
              height: pet == null
                  ? alturaCabecalho
                  : offsetEtiqueta + alturaEtiqueta,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    width: double.infinity,
                    height: alturaCabecalho,
                    decoration: const BoxDecoration(
                      color: VetCores.rosaEscuro,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 19),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 50,
                                ),
                                child: Text(
                                  'Pet',
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
                                  onPressed: widget.onVoltar,
                                  icon: const Icon(Icons.arrow_back_rounded),
                                  color: VetCores.branco,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (pet != null)
                    Positioned(
                      top: offsetEtiqueta,
                      child: EtiquetaPerfil(
                        compacto: compacto,
                        nome: pet.nome,
                        fotoPerfilPath: pet.fotoPerfilPath,
                        onSelecionarFoto: _selecionarFoto,
                      ),
                    ),
                ],
              ),
            ),
            if (pet == null)
              const Expanded(
                child: Center(child: Text('Não foi possível encontrar o pet.')),
              )
            else
              Expanded(
                child: Column(
                  children: [
                    SizedBox(height: espacamento),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: BotaoEstilizado(
                              texto: 'Detalhes',
                              onPressed: _abrirDetalhes,
                              largura: 150,
                              altura: alturaBotoesPerfil,
                              tamanhoFonte: 16,
                            ),
                          ),
                          const SizedBox(width: 20),
                          const Flexible(
                            child: BotaoEstilizado(
                              texto: 'Vacinações',
                              onPressed: null,
                              largura: 150,
                              altura: alturaBotoesPerfil,
                              tamanhoFonte: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: espacamento),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, areaCartao) {
                          final alturaCartao = math.min(
                            250.0,
                            areaCartao.maxHeight,
                          );
                          return Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: _cartaoAgendamentos(alturaCartao),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: telaBaixa ? 4 : (compacto ? 16 : 20)),
                    SizedBox(
                      width: larguraBotaoConsulta,
                      height: alturaBotaoConsulta,
                      child: ElevatedButton(
                        onPressed: _agendarConsulta,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: VetCores.marrom,
                          foregroundColor: VetCores.branco,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        child: Text(
                          'Nova Consulta',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.comfortaa(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: telaBaixa ? 4 : 14),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
