import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_vethome/models/usuario.dart';
import 'package:flutter_vethome/pages/carregamento.dart';
import 'package:flutter_vethome/repositories/usuario_repository.dart';
import 'package:flutter_vethome/services/cep_lookup_service.dart';
import 'menu_page.dart';
import 'package:flutter_vethome/widgets/campo_cadastro.dart';
import 'package:flutter_vethome/widgets/botao_cadastrar.dart';

class InformacoesCadastroPage extends StatefulWidget {
  const InformacoesCadastroPage({
    super.key,
    this.usuarioRepository,
    this.cepLookupService,
  });

  final UsuarioRepository? usuarioRepository;
  final CepLookupService? cepLookupService;

  @override
  State<InformacoesCadastroPage> createState() =>
      _InformacoesCadastroPageState();
}

class _InformacoesCadastroPageState extends State<InformacoesCadastroPage> {
  late final UsuarioRepository _repository;
  late final CepLookupService _cepLookupService;
  final _nomeController = TextEditingController();
  final _dataNascimentoController = TextEditingController();
  final _generoController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _confirmarTelefoneController = TextEditingController();
  final _cepController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _numeroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _complementoController = TextEditingController();
  final _emailController = TextEditingController();
  final _confirmarEmailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  final Map<String, String> _errors = <String, String>{};
  GeneroUsuario? _genero;
  int _cepRequestId = 0;
  bool _consultandoCep = false;
  String? _cepFeedback;

  @override
  void initState() {
    super.initState();
    _repository =
        widget.usuarioRepository ?? InMemoryUsuarioRepository.instance;
    _cepLookupService = widget.cepLookupService ?? ViaCepLookupService();
  }

  @override
  void dispose() {
    for (final controller in [
      _nomeController,
      _dataNascimentoController,
      _generoController,
      _cpfController,
      _telefoneController,
      _confirmarTelefoneController,
      _cepController,
      _enderecoController,
      _numeroController,
      _cidadeController,
      _complementoController,
      _emailController,
      _confirmarEmailController,
      _senhaController,
      _confirmarSenhaController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF68442E),
        content: Text(mensagem),
      ),
    );
  }

  Future<void> _selecionarData() async {
    final hoje = DateTime.now();
    final data = await showDatePicker(
      context: context,
      initialDate: DateTime(hoje.year - 18, hoje.month, hoje.day),
      firstDate: DateTime(1900),
      lastDate: hoje,
    );

    if (data != null) {
      setState(() {
        _dataNascimentoController.text =
            '${data.day.toString().padLeft(2, '0')}/'
            '${data.month.toString().padLeft(2, '0')}/${data.year}';
        _errors.remove('dataNascimento');
      });
    }
  }

  Future<void> _selecionarGenero() async {
    final genero = await showModalBottomSheet<GeneroUsuario>(
      context: context,
      backgroundColor: const Color(0xFFFAD3D5),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Selecione uma opção',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            for (final opcao in GeneroUsuario.values)
              ListTile(
                title: Text(_nomeGenero(opcao)),
                trailing: _genero == opcao
                    ? const Icon(Icons.check, color: Color(0xFF68442E))
                    : null,
                onTap: () => Navigator.pop(context, opcao),
              ),
          ],
        ),
      ),
    );

    if (genero != null) {
      setState(() {
        _genero = genero;
        _generoController.text = _nomeGenero(genero);
        _errors.remove('genero');
      });
    }
  }

  String _nomeGenero(GeneroUsuario genero) {
    return switch (genero) {
      GeneroUsuario.feminino => 'Feminino',
      GeneroUsuario.masculino => 'Masculino',
      GeneroUsuario.outro => 'Outro',
      GeneroUsuario.prefiroNaoInformar => 'Prefiro não informar',
    };
  }

  String _somenteNumeros(String valor) => valor.replaceAll(RegExp(r'\D'), '');

  void _aoAlterarCep(String valor) {
    final cep = _somenteNumeros(valor);
    final requestId = ++_cepRequestId;
    if (cep.length != 8) {
      if (_consultandoCep || _cepFeedback != null) {
        setState(() {
          _consultandoCep = false;
          _cepFeedback = null;
        });
      }
      return;
    }

    setState(() {
      _consultandoCep = true;
      _cepFeedback = null;
      _errors.remove('cep');
    });
    unawaited(_consultarCep(cep, requestId));
  }

  Future<void> _consultarCep(String cep, int requestId) async {
    try {
      final endereco = await _cepLookupService.consultar(cep);
      if (!mounted || requestId != _cepRequestId) return;

      setState(() {
        _consultandoCep = false;
        if (endereco == null) {
          _cepFeedback = 'CEP não encontrado. Confira ou preencha manualmente.';
          return;
        }
        if (endereco.logradouro.isNotEmpty) {
          _enderecoController.text = endereco.logradouro;
        }
        if (endereco.cidade.isNotEmpty) {
          _cidadeController.text = endereco.cidade;
        }
        _cepFeedback = 'Endereço e cidade preenchidos.';
      });
    } catch (_) {
      if (!mounted || requestId != _cepRequestId) return;
      setState(() {
        _consultandoCep = false;
        _cepFeedback = 'Falha na consulta. Você pode preencher manualmente.';
      });
    }
  }

  void _cadastrar() {
    final usuario = Usuario(
      nome: _nomeController.text,
      dataNascimento: _parseDataNascimento(_dataNascimentoController.text),
      genero: _genero,
      cpf: _cpfController.text,
      telefone: _telefoneController.text,
      cep: _cepController.text,
      endereco: _enderecoController.text,
      numero: _numeroController.text,
      complemento: _complementoController.text,
      cidade: _cidadeController.text,
      email: _emailController.text,
    );
    final errors = <String, String>{...usuario.errors};
    final telefone = _somenteNumeros(_telefoneController.text);
    final confirmarTelefone = _somenteNumeros(
      _confirmarTelefoneController.text,
    );

    if (telefone != confirmarTelefone) {
      errors['confirmarTelefone'] = 'Os telefones não coincidem.';
    }
    if (Usuario.normalizeEmail(_emailController.text) !=
        Usuario.normalizeEmail(_confirmarEmailController.text)) {
      errors['confirmarEmail'] = 'Os e-mails não coincidem.';
    }
    final senha = _senhaController.text;
    if (senha.length < 8 ||
        !RegExp(r'[a-z]').hasMatch(senha) ||
        !RegExp(r'[A-Z]').hasMatch(senha) ||
        !RegExp(r'\d').hasMatch(senha)) {
      errors['senha'] =
          'Use 8 caracteres ou mais, com letras maiúsculas, minúsculas e números.';
    }
    if (senha != _confirmarSenhaController.text) {
      errors['confirmarSenha'] = 'As senhas não coincidem.';
    }
    if (_repository.findByEmail(usuario.email) != null) {
      errors['email'] = 'Este e-mail já está cadastrado.';
    }
    if (_repository.findByCpf(usuario.cpf) != null) {
      errors['cpf'] = 'Este CPF já está cadastrado.';
    }

    setState(() {
      _errors
        ..clear()
        ..addAll(errors);
    });

    if (errors.isNotEmpty) {
      _mostrarMensagem(errors.values.first);
      return;
    }

    try {
      _repository.save(usuario);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Carregamento(
            titulo: 'Cadastro realizado!',
            mensagem: 'Seus dados foram salvos com sucesso.',
            destinoBuilder: (context) => const MenuPage(),
          ),
        ),
      );
    } on ArgumentError catch (error) {
      _mostrarMensagem(error.message.toString());
    }
  }

  DateTime? _parseDataNascimento(String valor) {
    final partes = valor.split('/');
    if (partes.length != 3) return null;
    final dia = int.tryParse(partes[0]);
    final mes = int.tryParse(partes[1]);
    final ano = int.tryParse(partes[2]);
    if (dia == null || mes == null || ano == null) return null;

    final data = DateTime(ano, mes, dia);
    if (data.day != dia || data.month != mes || data.year != ano) return null;
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAD3D5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAD3D5),
        foregroundColor: const Color(0xFF68442E),
        title: Text(
          'Cadastro',
          style: GoogleFonts.comfortaa(
            color: const Color(0xFF68442E),
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compacto =
                constraints.maxWidth < 500 || constraints.maxHeight < 700;
            final double espacamentoInicial = compacto ? 20 : 40;
            final double espacamentoCampos = compacto ? 7 : 10;
            final double alturaCampos = compacto ? 50 : 57;
            final double larguraCampos = compacto ? 400 : 500;
            final double tamanhoIcone = compacto ? 52 : 58;
            final double tamanhoIconeInterno = compacto ? 28 : 35;
            final double fonteLabel = compacto ? 14 : 17;
            final double larguraBotao = compacto ? 150 : 180;
            final double alturaBotao = compacto ? 54 : 62;
            final double fonteBotao = compacto ? 16 : 18;

            Widget campo({
              required String titulo,
              required IconData icone,
              required TextEditingController controller,
              required String errorKey,
              TextInputType keyboardType = TextInputType.text,
              TextCapitalization textCapitalization = TextCapitalization.none,
              bool obscureText = false,
              VoidCallback? onTap,
              ValueChanged<String>? onChanged,
              List<String> limparErros = const [],
            }) {
              return CampoCadastro(
                titulo: titulo,
                icone: icone,
                altura: alturaCampos,
                largura: larguraCampos,
                tamanhoIcone: tamanhoIcone,
                tamanhoIconeInterno: tamanhoIconeInterno,
                fonteLabel: fonteLabel,
                controller: controller,
                errorText: _errors[errorKey],
                keyboardType: keyboardType,
                textCapitalization: textCapitalization,
                obscureText: obscureText,
                onTap: onTap,
                onChanged: (value) {
                  final chaves = [errorKey, ...limparErros];
                  if (chaves.any(_errors.containsKey)) {
                    setState(() {
                      for (final chave in chaves) {
                        _errors.remove(chave);
                      }
                    });
                  }
                  onChanged?.call(value);
                },
              );
            }

            final campos = <Widget>[
              campo(
                titulo: 'Nome Completo',
                icone: Icons.person,
                controller: _nomeController,
                errorKey: 'nome',
                textCapitalization: TextCapitalization.words,
              ),
              SizedBox(height: espacamentoCampos),
              campo(
                titulo: 'Data de Nascimento',
                icone: Icons.calendar_month,
                controller: _dataNascimentoController,
                errorKey: 'dataNascimento',
                keyboardType: TextInputType.none,
                onTap: _selecionarData,
              ),
              SizedBox(height: espacamentoCampos),
              campo(
                titulo: 'Gênero/Sexo',
                icone: Icons.wc,
                controller: _generoController,
                errorKey: 'genero',
                keyboardType: TextInputType.none,
                onTap: _selecionarGenero,
              ),
              SizedBox(height: espacamentoCampos),
              campo(
                titulo: 'CPF',
                icone: Icons.badge,
                controller: _cpfController,
                errorKey: 'cpf',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: espacamentoCampos),
              campo(
                titulo: 'Telefone/Celular',
                icone: Icons.phone,
                controller: _telefoneController,
                errorKey: 'telefone',
                keyboardType: TextInputType.phone,
                limparErros: ['confirmarTelefone'],
              ),
              SizedBox(height: espacamentoCampos),
              campo(
                titulo: 'Confirmar Telefone/Celular',
                icone: Icons.phone,
                controller: _confirmarTelefoneController,
                errorKey: 'confirmarTelefone',
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: espacamentoCampos),
              campo(
                titulo: 'CEP',
                icone: Icons.home,
                controller: _cepController,
                errorKey: 'cep',
                keyboardType: TextInputType.number,
                onChanged: _aoAlterarCep,
              ),
              if (_consultandoCep)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF68442E),
                    ),
                  ),
                )
              else if (_cepFeedback != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _cepFeedback!,
                    style: const TextStyle(
                      color: Color(0xFF68442E),
                      fontSize: 12,
                    ),
                  ),
                ),
              SizedBox(height: espacamentoCampos),
              campo(
                titulo: 'Endereço',
                icone: Icons.home,
                controller: _enderecoController,
                errorKey: 'endereco',
                textCapitalization: TextCapitalization.words,
              ),
              SizedBox(height: espacamentoCampos),
              campo(
                titulo: 'Número',
                icone: Icons.numbers,
                controller: _numeroController,
                errorKey: 'numero',
              ),
              SizedBox(height: espacamentoCampos),
              campo(
                titulo: 'Cidade',
                icone: Icons.location_city,
                controller: _cidadeController,
                errorKey: 'cidade',
                textCapitalization: TextCapitalization.words,
              ),
              SizedBox(height: espacamentoCampos),
              campo(
                titulo: 'Complemento',
                icone: Icons.home,
                controller: _complementoController,
                errorKey: 'complemento',
              ),
              SizedBox(height: espacamentoCampos),
              campo(
                titulo: 'E-mail',
                icone: Icons.email,
                controller: _emailController,
                errorKey: 'email',
                keyboardType: TextInputType.emailAddress,
                limparErros: ['confirmarEmail'],
              ),
              SizedBox(height: espacamentoCampos),
              campo(
                titulo: 'Confirmar E-mail',
                icone: Icons.email,
                controller: _confirmarEmailController,
                errorKey: 'confirmarEmail',
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: espacamentoCampos),
              campo(
                titulo: 'Senha',
                icone: Icons.lock,
                controller: _senhaController,
                errorKey: 'senha',
                obscureText: true,
                limparErros: ['confirmarSenha'],
              ),
              SizedBox(height: espacamentoCampos),
              campo(
                titulo: 'Confirmar Senha',
                icone: Icons.lock,
                controller: _confirmarSenhaController,
                errorKey: 'confirmarSenha',
                obscureText: true,
              ),
            ];

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: compacto ? 16 : 24,
                vertical: 20,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: espacamentoInicial),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: compacto ? 10 : 16,
                          vertical: compacto ? 16 : 22,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(255, 255, 255, 0.2),
                          borderRadius: BorderRadius.circular(35),
                          border: Border.all(
                            color: const Color(
                              0xFFC08081,
                            ).withValues(alpha: 0.75),
                            width: 2.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: campos,
                        ),
                      ),
                      const SizedBox(height: 30),
                      BotaoCadastro(
                        largura: larguraBotao,
                        altura: alturaBotao,
                        fonte: fonteBotao,
                        onPressed: _cadastrar,
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
