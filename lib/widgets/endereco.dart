import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vethome/models/usuario.dart';
import 'package:flutter_vethome/services/cep_lookup_service.dart';
import 'package:flutter_vethome/themes/vet_cores.dart';
import 'package:flutter_vethome/widgets/botao_estilizado.dart';
import 'package:flutter_vethome/widgets/campo_cadastro.dart';
import 'package:google_fonts/google_fonts.dart';

class NovoEndereco extends StatefulWidget {
  const NovoEndereco({super.key, this.cepLookupService, this.enderecoInicial});

  final CepLookupService? cepLookupService;
  final EnderecoUsuario? enderecoInicial;

  @override
  State<NovoEndereco> createState() => _NovoEnderecoState();
}

class _NovoEnderecoState extends State<NovoEndereco> {
  late final CepLookupService _cepLookupService =
      widget.cepLookupService ?? ViaCepLookupService();
  final _nomeController = TextEditingController();
  final _cepController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _cidadeController = TextEditingController();
  final Map<String, String> _errors = {};
  int _cepRequestId = 0;
  bool _consultandoCep = false;
  bool _validandoEndereco = false;
  String? _cepFeedback;

  @override
  void initState() {
    super.initState();
    final endereco = widget.enderecoInicial;
    if (endereco != null) {
      _nomeController.text = endereco.nome;
      _cepController.text = endereco.cep;
      _logradouroController.text = endereco.logradouro;
      _numeroController.text = endereco.numero;
      _complementoController.text = endereco.complemento;
      _cidadeController.text = endereco.cidade;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cepController.dispose();
    _logradouroController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    _cidadeController.dispose();
    super.dispose();
  }

  EnderecoUsuario _enderecoAtual() => EnderecoUsuario(
    nome: _nomeController.text.trim(),
    cep: _cepController.text.trim(),
    logradouro: _logradouroController.text.trim(),
    numero: _numeroController.text.trim(),
    complemento: _complementoController.text.trim(),
    cidade: _cidadeController.text.trim(),
  );

  bool _mesmoEndereco(EnderecoUsuario a, EnderecoUsuario b) =>
      a.nome.trim() == b.nome.trim() &&
      a.cep.replaceAll(RegExp(r'\D'), '') ==
          b.cep.replaceAll(RegExp(r'\D'), '') &&
      a.logradouro.trim() == b.logradouro.trim() &&
      a.numero.trim() == b.numero.trim() &&
      a.complemento.trim() == b.complemento.trim() &&
      a.cidade.trim() == b.cidade.trim();

  Future<void> _salvar() async {
    if (_validandoEndereco) return;
    final errors = <String, String>{
      if (_nomeController.text.trim().isEmpty)
        'nome do endereço': 'Campo obrigatório',
      if (_cepController.text.replaceAll(RegExp(r'\D'), '').length != 8)
        'cep': 'Informe um CEP válido',
      if (_logradouroController.text.trim().isEmpty)
        'logradouro': 'Campo obrigatório',
      if (_numeroController.text.trim().isEmpty)
        'número': 'Campo obrigatório'
      else if (!RegExp(r'^[0-9]+$').hasMatch(_numeroController.text.trim()))
        'número': 'Informe apenas números',
      if (_cidadeController.text.trim().isEmpty) 'cidade': 'Campo obrigatório',
    };
    setState(() {
      _errors
        ..clear()
        ..addAll(errors);
    });
    if (errors.isNotEmpty) return;
    final endereco = _enderecoAtual();
    final inicial = widget.enderecoInicial;
    if (inicial != null && _mesmoEndereco(endereco, inicial)) {
      setState(() => _cepFeedback = 'Primeiro edite algum campo.');
      return;
    }

    ++_cepRequestId;
    setState(() {
      _validandoEndereco = true;
      _consultandoCep = false;
      _cepFeedback = null;
    });
    try {
      final consulta = await _cepLookupService.consultar(endereco.cep);
      if (!mounted) return;
      if (!_mesmoEndereco(endereco, _enderecoAtual())) {
        setState(() => _cepFeedback = 'Os dados mudaram. Salve novamente.');
        return;
      }
      final erroCep = validarEnderecoCep(
        consulta,
        logradouro: endereco.logradouro,
        cidade: endereco.cidade,
      );
      if (erroCep != null) {
        setState(() => _cepFeedback = erroCep);
        return;
      }
      Navigator.of(context).pop(endereco);
    } catch (_) {
      if (mounted) {
        setState(() => _cepFeedback =
            'Não foi possível consultar o CEP. Tente novamente.');
      }
    } finally {
      if (mounted) setState(() => _validandoEndereco = false);
    }
  }

  void _aoAlterarCep(String valor) {
    final cep = valor.replaceAll(RegExp(r'\D'), '');
    final requestId = ++_cepRequestId;
    setState(() {
      _consultandoCep = cep.length == 8;
      _cepFeedback = null;
    });
    if (cep.length == 8) {
      unawaited(_consultarCep(cep, requestId));
    }
  }

  Future<void> _consultarCep(String cep, int requestId) async {
    final logradouroAnterior = _logradouroController.text;
    final cidadeAnterior = _cidadeController.text;
    try {
      final endereco = await _cepLookupService.consultar(cep);
      if (!mounted || requestId != _cepRequestId) return;
      setState(() {
        _consultandoCep = false;
        if (endereco == null) {
          _cepFeedback = 'CEP não encontrado. Confira o CEP informado.';
          return;
        }
        if (endereco.logradouro.isNotEmpty &&
            _logradouroController.text == logradouroAnterior) {
          _logradouroController.text = endereco.logradouro;
          _errors.remove('logradouro');
        }
        if (endereco.cidade.isNotEmpty &&
            _cidadeController.text == cidadeAnterior) {
          _cidadeController.text = endereco.cidade;
          _errors.remove('cidade');
        }
        _cepFeedback = 'Consulta de CEP concluída.';
      });
    } catch (_) {
      if (!mounted || requestId != _cepRequestId) return;
      setState(() {
        _consultandoCep = false;
        _cepFeedback = 'Falha na consulta. Tente novamente.';
      });
    }
  }

  Widget _campo(
    String label,
    TextEditingController controller, {
    required IconData icone,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
  }) {
    final chave = label.toLowerCase();
    final erro = _errors[chave];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CampoCadastro(
            key: ValueKey('novo-endereco-$chave'),
            titulo: label,
            icone: icone,
            altura: 55,
            largura: double.infinity,
            tamanhoIcone: 55,
            tamanhoIconeInterno: 27,
            fonteLabel: 15,
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            textCapitalization: TextCapitalization.words,
            onChanged: (valor) {
              if (_errors.containsKey(chave)) {
                setState(() => _errors.remove(chave));
              }
              onChanged?.call(valor);
            },
          ),
          if (erro != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 8),
              child: Text(
                erro,
                style: const TextStyle(
                  color: VetCores.vermelhoEscuro,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: VetCores.rosaFundo,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      title: Text(
        widget.enderecoInicial == null ? 'Adicionar endereço' : 'Editar endereço',
        style: GoogleFonts.comfortaa(
          color: VetCores.marrom,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: 330,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _campo('Nome do endereço', _nomeController, icone: Icons.label),
              _campo(
                'CEP',
                _cepController,
                icone: Icons.home,
                keyboardType: TextInputType.number,
                onChanged: _aoAlterarCep,
              ),
              if (_consultandoCep)
                const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: VetCores.marrom,
                    ),
                  ),
                )
              else if (_cepFeedback != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    _cepFeedback!,
                    style: const TextStyle(
                      color: VetCores.marrom,
                      fontSize: 12,
                    ),
                  ),
                ),
              _campo('Logradouro', _logradouroController, icone: Icons.home),
              _campo(
                'Número',
                _numeroController,
                icone: Icons.numbers,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              _campo('Cidade', _cidadeController, icone: Icons.location_city),
              _campo('Complemento', _complementoController, icone: Icons.home),
            ],
          ),
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: BotaoEstilizado(
                texto: 'Cancelar',
                largura: 125,
                altura: 49,
                tamanhoFonte: 16,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: SizedBox(
                width: 125,
                height: 49,
                child: ElevatedButton(
                  key: const ValueKey('salvar-novo-endereco'),
                  onPressed: _validandoEndereco ? null : _salvar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VetCores.marrom,
                    foregroundColor: VetCores.branco,
                  ),
                  child: Text(
                    'Salvar',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.comfortaa(
                      color: VetCores.branco,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
