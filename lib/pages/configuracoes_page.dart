import 'package:flutter/material.dart';
import 'package:flutter_vethome/pages/historico_agendamento_page.dart';
import 'package:flutter_vethome/pages/lista_enderecos.dart';
import 'package:flutter_vethome/pages/login_page.dart';
import 'package:flutter_vethome/repositories/agendamento_repository.dart';
import 'package:flutter_vethome/repositories/pet_repository.dart';
import 'package:flutter_vethome/repositories/usuario_repository.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_vethome/themes/vet_cores.dart';
import 'package:flutter_vethome/widgets/opcao.dart';

class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({
    super.key,
    this.usuarioRepository,
    this.usuarioId,
    this.agendamentoRepository,
    this.petRepository,
  });

  final UsuarioRepository? usuarioRepository;
  final String? usuarioId;
  final AgendamentoRepository? agendamentoRepository;
  final PetRepository? petRepository;

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPage();
}

class _ConfiguracoesPage extends State<ConfiguracoesPage> {
  void _abrirTemas() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: VetCores.rosaFundo,
        title: Text(
          'Tema do Aplicativo',
          style: GoogleFonts.comfortaa(
            color: VetCores.marrom,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final tema in ['Modo escuro', 'Modo personalizado'])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  '$tema — em breve',
                  style: GoogleFonts.comfortaa(color: VetCores.marrom),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _abrirEnderecos() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ListaEnderecos(
          usuarioRepository: widget.usuarioRepository,
          usuarioId: widget.usuarioId,
        ),
      ),
    );
  }

  void _abrirSuporte() {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: VetCores.rosaCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SizedBox(
          width: 250,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Suporte',
                  style: GoogleFonts.montserratAlternates(
                    color: VetCores.marrom,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Numero:',
                  style: GoogleFonts.comfortaa(
                    color: VetCores.marrom,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '11 9793-8918',
                  style: GoogleFonts.comfortaa(
                    color: VetCores.marrom,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Email:',
                  style: GoogleFonts.comfortaa(
                    color: VetCores.marrom,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Kelvinpro@gmail.com',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.comfortaa(
                    color: VetCores.marrom,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _abrirHistorico() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HistoricoAgendamentoPage(
          usuarioRepository: widget.usuarioRepository,
          usuarioId: widget.usuarioId,
          agendamentoRepository: widget.agendamentoRepository,
          petRepository: widget.petRepository,
        ),
      ),
    );
  }

  Future<void> _sair() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: VetCores.rosaCard,
        title: Text(
          'Deseja sair da sua conta?',
          style: GoogleFonts.comfortaa(
            color: VetCores.marrom,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: VetCores.marrom,
            ),
            child: Text(
              'Não',
              style: GoogleFonts.comfortaa(
                color: VetCores.marrom,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: VetCores.marrom,
              foregroundColor: VetCores.branco,
            ),
            child: Text(
              'Sim',
              style: GoogleFonts.comfortaa(
                color: VetCores.branco,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    if (!mounted || confirmar != true) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => LoginPage(usuarioRepository: widget.usuarioRepository),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool compacto =
            constraints.maxWidth < 500 || constraints.maxHeight < 700;
        final double alturaCabecalho = compacto ? 120 : 160;
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
                'Configurações',
                style: GoogleFonts.comfortaa(
                  color: VetCores.branco,
                  fontSize: compacto ? 30 : 35,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: compacto ? 30 : 35),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Opcao(
                    texto: 'Tema do Aplicativo',
                    compacto: compacto,
                    onTap: _abrirTemas,
                  ),
                  Divider(
                    height: 1,
                    thickness: 1.5,
                    color: VetCores.marrom25,
                  ),
                  Opcao(
                    texto: 'Meus Endereços',
                    compacto: compacto,
                    onTap: _abrirEnderecos,
                  ),
                  Divider(
                    height: 1,
                    thickness: 1.5,
                    color: VetCores.marrom25,
                  ),
                  Opcao(
                    texto: 'Suporte',
                    compacto: compacto,
                    onTap: _abrirSuporte,
                  ),
                  Divider(
                    height: 1,
                    thickness: 1.5,
                    color: VetCores.marrom25,
                  ),
                  Opcao(
                    texto: 'Histórico',
                    compacto: compacto,
                    onTap: _abrirHistorico,
                  ),
                  Divider(
                    height: 1,
                    thickness: 1.5,
                    color: VetCores.marrom25,
                  ),
                  Opcao(
                    texto: 'Sair',
                    compacto: compacto,
                    onTap: _sair,
                  ),
                ]
              )
            )
          ],
        );
      },
    );
  }
}