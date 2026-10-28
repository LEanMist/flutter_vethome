import 'package:flutter/material.dart';
import 'package:flutter_vethome/themes/vet_cores.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset;

class ContatoPage extends StatelessWidget {
  const ContatoPage({super.key});

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
                  color: Color(0xFFFFFFFF),
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
                          child: ListView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 4,
                            ),
                            children: const [
                              _MensagemChat(
                                nome: 'Gabriela Falcão',
                                texto:
                                    'Que tal experimentar um clássico feito na sua própria casa? Veja como preparar um brownie simples e rápido. Esta receita oferece uma maneira prática de criar esses deliciosos quadrados de chocolate, com ingredientes básicos como manteiga, ovos, achocolatado, açúcar e farinha de trigo.',
                              ),
                              _MensagemChat(
                                nome: 'Liminha',
                                texto:
                                    'Que tal experimentar um clássico feito na sua própria casa?',
                                enviada: true,
                              ),
                              _MensagemChat(
                                nome: 'Gabriela Falcão',
                                texto:
                                    'Que tal experimentar um clássico feito na sua própria casa? Veja como preparar um brownie simples e rápido. Cola sua boca para tu enche muito o saco namoral, que chatice',
                              ),
                              _MensagemChat(
                                nome: 'Liminha',
                                texto:
                                    'Que tal experimentar um clássico feito na sua própria casa? Veja como preparar um brownie simples e rápido.',
                                enviada: true,
                              ),
                            ],
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
                                            begin: Alignment(-1, -4),
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
                                    textAlign: TextAlign.center,
                                    cursorColor: VetCores.marrom,
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
                            const SizedBox(width: 12),
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: VetCores.marrom,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Icon(
                                Icons.send_rounded,
                                color: VetCores.branco,
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

  @override
  Widget build(BuildContext context) {
    final alinhamento = enviada ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: alinhamento,
        children: [
          if (!enviada)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 6, bottom: 3),
                child: Text(
                  nome,
                  style: const TextStyle(
                    color: Color(0xFF8F6B58),
                    fontSize: 18,
                  ),
                ),
              ),
            )
          else
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 6, bottom: 3),
                child: Text(
                  nome,
                  style: const TextStyle(
                    color: Color(0xFF8F6B58),
                    fontSize: 18,
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
                  ? const Color(0xFFAA8274)
                  : const Color(0xFFD8A3A3),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              texto,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
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