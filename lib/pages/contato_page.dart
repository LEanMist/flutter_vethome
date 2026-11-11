import 'package:flutter/material.dart';
import 'package:flutter_vethome/repositories/usuario_repository.dart';
import 'package:flutter_vethome/themes/vet_cores.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset;

class ContatoPage extends StatefulWidget {
  const ContatoPage({super.key, this.usuarioRepository});

  final UsuarioRepository? usuarioRepository;

  @override
  State<ContatoPage> createState() => _ContatoPageState();
}

class _ContatoPageState extends State<ContatoPage> {
  final _controladorMensagem = TextEditingController();
  final _controladorLista = ScrollController();
  late final List<Widget> _mensagens;

  UsuarioRepository get _repository =>
      widget.usuarioRepository ?? InMemoryUsuarioRepository.instance;

  String get _nomeUsuario {
    final usuarios = _repository.findAll();
    if (usuarios.isEmpty || usuarios.first.nome.trim().isEmpty) {
      return 'Nome não cadastrado';
    }
    return usuarios.first.nome.trim();
  }

  @override
  void initState() {
    super.initState();
    _mensagens = [
      const _MensagemChat(
        nome: 'Gabriela Falcão',
        texto:
            'Que tal experimentar um clássico feito na sua própria casa? Veja como preparar um brownie simples e rápido. Esta receita oferece uma maneira prática de criar esses deliciosos quadrados de chocolate, com ingredientes básicos como manteiga, ovos, achocolatado, açúcar e farinha de trigo.',
      ),
      _MensagemChat(
        nome: _nomeUsuario,
        texto: 'Que tal experimentar um clássico feito na sua própria casa?',
        enviada: true,
      ),
      const _MensagemChat(
        nome: 'Gabriela Falcão',
        texto:
            'Que tal experimentar um clássico feito na sua própria casa? Veja como preparar um brownie simples e rápido. Cola sua boca para tu enche muito o saco namoral, que chatice',
      ),
      _MensagemChat(
        nome: _nomeUsuario,
        texto:
            'Que tal experimentar um clássico feito na sua própria casa? Veja como preparar um brownie simples e rápido.',
        enviada: true,
      ),
    ];
  }

  void _enviarMensagem() {
    final texto = _controladorMensagem.text.trim();
    if (texto.isEmpty) return;

    setState(() {
      _mensagens.add(
        _MensagemChat(nome: _nomeUsuario, texto: texto, enviada: true),
      );
    });
    _controladorMensagem.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controladorLista.hasClients) {
        _controladorLista.animateTo(
          _controladorLista.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controladorMensagem.dispose();
    _controladorLista.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool compacto =
            constraints.maxWidth < 500 || constraints.maxHeight < 700;
        final double alturaCabecalho = compacto ? 140 : 160;
        return Column(
          children: [
            Container(
              width: double.infinity,
              height: alturaCabecalho,
              decoration: BoxDecoration(
                color: VetCores.rosaEscuro,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(top: 30),
              child: Text(
                'Contato',
                style: GoogleFonts.comfortaa(
                  color: VetCores.branco,
                  fontSize: compacto ? 30 : 35,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: compacto ? 20 : 30),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: inset.BoxDecoration(
                      color: VetCores.rosaEscuro25,
                      borderRadius: BorderRadius.circular(35),
                      boxShadow: const [
                        inset.BoxShadow(
                          color: Color.fromARGB(55, 70, 40, 41),
                          blurRadius: 1,
                          offset: Offset(3, 3),
                          inset: true,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            controller: _controladorLista,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 4,
                            ),
                            itemCount: _mensagens.length,
                            itemBuilder: (context, index) => _mensagens[index],
                          ),
                        ),
                        SizedBox(height: compacto ? 15 : 30),
                        Row(
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Opacity(
                                      opacity: 0.5,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            begin:  Alignment(-1, -4),
                                            end: Alignment(1, 4),
                                            colors: [
                                              VetCores.rosaFundo,
                                              VetCores.rosaEscuro75,
                                            ],
                                            stops: [0.25, 1.0],
                                          ),
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                      ),
                                    ),
                                  ),
                                  TextField(
                                    controller: _controladorMensagem,
                                    textAlign: TextAlign.center,
                                    cursorColor: VetCores.marrom,
                                    onSubmitted: (_) => _enviarMensagem(),
                                    decoration: InputDecoration(
                                      hintText: 'Mensagem',
                                      hintStyle: GoogleFonts.comfortaa(
                                        color: VetCores.marrom50,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      filled: true,
                                      fillColor: Colors.transparent,
                                      contentPadding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 12,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: compacto ? 12 : 20),
                            SizedBox(
                              width: 48,
                              height: 48,
                              child: IconButton(
                                tooltip: 'Enviar mensagem',
                                onPressed: _enviarMensagem,
                                style: IconButton.styleFrom(
                                  backgroundColor: VetCores.marrom,
                                  foregroundColor: VetCores.branco,
                                  shape: const CircleBorder(),
                                  padding: EdgeInsets.zero,
                                ),
                                icon: const Icon(Icons.send_rounded),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: compacto ? 20 : 30),
          ],
        );
      },
    );
  }
}

class _MensagemChat extends StatelessWidget {
  const _MensagemChat({
    required this.nome,
    required this.texto,
    this.enviada = false,
  });

  final String nome;
  final String texto;
  final bool enviada;

  static const double _tamanhoFonteNome = 20;
  static const double _tamanhoFonteMensagem = 12;

  @override
  Widget build(BuildContext context) {
    final alinhamento = enviada ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: alinhamento,
        children: [
          Align(
            alignment: enviada ? Alignment.centerRight : Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(
                left: enviada ? 0 : 6,
                right: enviada ? 6 : 0,
                bottom: 3,
              ),
              child: Text(
                nome,
                style: GoogleFonts.comfortaa(
                  color: VetCores.marrom75,
                  fontSize: _tamanhoFonteNome,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.72,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            decoration: BoxDecoration(
              color: enviada
                  ? VetCores.marrom50
                  : const Color(0xFFD8A3A3),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              texto,
              style: GoogleFonts.comfortaa(
                color: VetCores.branco,
                fontSize: _tamanhoFonteMensagem,
              ),
            ),
          ),
          if (!enviada)
            const Align(
              alignment: Alignment.centerLeft,
              child: Icon(Icons.done_all, size: 14, color: Color(0xFF8F6B58)),
            )
          else
            const Align(
              alignment: Alignment.centerRight,
              child: Icon(Icons.done_all, size: 14, color: Color(0xFF8F6B58)),
            ),
        ],
      ),
    );
  }
}