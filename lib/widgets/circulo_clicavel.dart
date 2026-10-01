import 'package:flutter/material.dart';

class CirculoClicavel extends StatelessWidget {
  final String? imagem;
  final IconData? icone;
  final bool selecionado;
  final String? tooltip;
  final VoidCallback onPressed;

  const CirculoClicavel({
    super.key,
    this.imagem,
    this.icone,
    this.selecionado = false,
    this.tooltip,
    required this.onPressed,
  }) : assert((imagem == null) != (icone == null));

  @override
  Widget build(BuildContext context) {
    final Widget conteudo = imagem != null
        ? Image.asset(imagem!, width: 30, height: 30, fit: BoxFit.contain)
        : Icon(
            icone,
            size: 37,
            color: selecionado ? Colors.white : const Color(0xFF68442E),
          );

    return SizedBox(
      width: 52,
      height: 52,
      child: Container(
        decoration: BoxDecoration(
          color: selecionado
              ? const Color(0xFFC08081)
              : const Color(0xFFFAD3D5),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(100, 105, 66, 67),
              blurRadius: 1,
              offset: Offset(2, 3),
            ),
          ],
        ),
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.transparent,
            side: BorderSide.none,
            shape: const CircleBorder(),
            padding: EdgeInsets.zero,
          ),
          child: tooltip == null
              ? conteudo
              : Tooltip(message: tooltip!, child: conteudo),
        ),
      ),
    );
  }
}
