import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_vethome/pages/carregamento.dart';
import 'package:flutter_vethome/widgets/campo_cadastro.dart';
import 'package:flutter_vethome/widgets/botao_cadastrar.dart';

class CadastroPetPage extends StatefulWidget {
  const CadastroPetPage({
    super.key,
    required this.destinoBuilder,
  });

  final WidgetBuilder destinoBuilder;

  @override
  State<CadastroPetPage> createState() => _CadastroPetPage();
}

class _CadastroPetPage extends State<CadastroPetPage> {
  void menu(){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Carregamento(
          titulo: 'Pet cadastrado com sucesso!',
          mensagem: null,
          destinoBuilder: widget.destinoBuilder,
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAD3D5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAD3D5),
        foregroundColor: const Color(0xFF68442E),
        title: Text(
          'Cadastro Pet',
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
          builder: (context, constraints){
            final compacto =
                constraints.maxWidth < 500 || constraints.maxHeight < 700;
            final double espacamentoInicial = compacto ? 20 : 40;
            final double espacamentoCampos = compacto ? 14 : 10;
            final double alturaCampos = compacto ? 55 : 57;
            final double larguraCampos = compacto ? 400 : 500;
            final double tamanhoIcone = compacto ? 57 : 58;
            final double tamanhoIconeInterno = compacto ? 30 : 35;
            final double fonteLabel = compacto ? 16 : 17; 
            final double larguraBotao = compacto? 180 : 180;
            final double alturaBotao = compacto? 70 : 62;
            final double fonteBotao = compacto? 18 : 18;

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: compacto? 16 : 24, 
                vertical: 20,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: espacamentoInicial,),

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
                              color: const Color(0xFFC08081).withValues(alpha: 0.75),
                              width: 2.5,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CampoCadastro(
                                titulo: 'Tipo de Animal',
                                icone: Icons.pets,
                                altura: alturaCampos,
                                largura: larguraCampos,
                                tamanhoIcone: tamanhoIcone,
                                tamanhoIconeInterno: tamanhoIconeInterno,
                                fonteLabel: fonteLabel,
                              ),

                              SizedBox(height: espacamentoCampos,),
                              CampoCadastro(
                                titulo: 'Nome do Cachorro(a)',
                                icone: Icons.pets,
                                altura: alturaCampos,
                                largura: larguraCampos,
                                tamanhoIcone: tamanhoIcone,
                                tamanhoIconeInterno: tamanhoIconeInterno,
                                fonteLabel: fonteLabel,
                              ),

                              SizedBox(height: espacamentoCampos,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: CampoCadastro(
                                      titulo: 'Gênero/Sexo',
                                      icone: Icons.transgender,
                                      altura: alturaCampos,
                                      largura: double.infinity,
                                      tamanhoIcone: tamanhoIcone,
                                      tamanhoIconeInterno:
                                          tamanhoIconeInterno,
                                      fonteLabel: fonteLabel,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: CampoCadastro(
                                      titulo: 'peso',
                                      icone: Icons.monitor_weight,
                                      altura: alturaCampos,
                                      largura: double.infinity,
                                      tamanhoIcone: tamanhoIcone,
                                      tamanhoIconeInterno:
                                          tamanhoIconeInterno,
                                      fonteLabel: fonteLabel,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: espacamentoCampos,),
                              CampoCadastro(
                                titulo: 'Data de Nascimento',
                                icone: Icons.cake,
                                altura: alturaCampos,
                                largura: larguraCampos,
                                tamanhoIcone: tamanhoIcone,
                                tamanhoIconeInterno: tamanhoIconeInterno,
                                fonteLabel: fonteLabel,
                              ),

                              SizedBox(height: espacamentoCampos,),
                              CampoCadastro(
                                titulo: 'Raça',
                                icone: Icons.category,
                                altura: alturaCampos,
                                largura: larguraCampos,
                                tamanhoIcone: tamanhoIcone,
                                tamanhoIconeInterno: tamanhoIconeInterno,
                                fonteLabel: fonteLabel,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30,),

                        BotaoCadastro(
                        largura: larguraBotao,
                        altura: alturaBotao,
                        fonte: fonteBotao,
                        onPressed: menu,
                      ),
                        const SizedBox(height: 30,),
                    ],
                  ),
                )
              ),
            );
          }
        )
      )
    );
  }
}
