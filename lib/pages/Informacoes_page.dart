import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset_shadow;

class InformacoesCadastroPage extends StatefulWidget {
  const InformacoesCadastroPage({super.key});

  @override
  State<InformacoesCadastroPage> createState() => _InformacoesCadastroPageState();
}

class _InformacoesCadastroPageState extends State<InformacoesCadastroPage> {
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
          builder: (context, constraints){
            final compacto =
                constraints.maxWidth < 500 || constraints.maxHeight < 700;
            final double espacamentoInicial = compacto ? 20 : 40;
            final double espacamentoCampos = compacto ? 7 : 10;
            final double alturaCampos = compacto ? 42 : 62;
            final double tamanhoIcone = compacto ? 48 : 54;
            final double tamanhoIconeInterno = compacto ? 26 : 30;
            final double fonteLabel = compacto ? 14 : 17; 
            final double larguraBotao = compacto? 150 : 180;
            final double alturaBotao = compacto? 54 : 62;
            final double fonteBotao = compacto? 16 : 18;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
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
                            horizontal: compacto ? 14 : 20,
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
                              _campo(
                                titulo: 'Nome Completo',
                                icone: Icons.person,
                                altura: alturaCampos,
                                tamanhoIcone: tamanhoIcone,
                                tamanhoIconeInterno: tamanhoIconeInterno,
                                fonteLabel: fonteLabel,
                              ),

                              SizedBox(height: espacamentoCampos,),
                              _campo(
                                titulo: 'Data de Nascimento',
                                icone: Icons.calendar_month,
                                altura: alturaCampos,
                                tamanhoIcone: tamanhoIcone,
                                tamanhoIconeInterno: tamanhoIconeInterno,
                                fonteLabel: fonteLabel,
                              ),

                              SizedBox(height: espacamentoCampos,),
                              _campo(
                                titulo: 'Gênero/Sexo',
                                icone: Icons.wc,
                                altura: alturaCampos,
                                tamanhoIcone: tamanhoIcone,
                                tamanhoIconeInterno: tamanhoIconeInterno,
                                fonteLabel: fonteLabel,
                              ),

                              SizedBox(height: espacamentoCampos,),
                              _campo(
                                titulo: 'CPF',
                                icone: Icons.badge,
                                altura: alturaCampos,
                                tamanhoIcone: tamanhoIcone,
                                tamanhoIconeInterno: tamanhoIconeInterno,
                                fonteLabel: fonteLabel,
                              ),

                              SizedBox(height: espacamentoCampos,),
                              _campo(
                                titulo: 'Telefone/Celular',
                                icone: Icons.phone,
                                altura: alturaCampos,
                                tamanhoIcone: tamanhoIcone,
                                tamanhoIconeInterno: tamanhoIconeInterno,
                                fonteLabel: fonteLabel,
                              ),

                              SizedBox(height: espacamentoCampos,),
                              _campo(
                                titulo: 'Confirmar Telefone/Celular',
                                icone: Icons.phone,
                                altura: alturaCampos,
                                tamanhoIcone: tamanhoIcone,
                                tamanhoIconeInterno: tamanhoIconeInterno,
                                fonteLabel: fonteLabel,
                              ),

                              SizedBox(height: espacamentoCampos,),
                              _campo(
                                titulo: 'CEP',
                                icone: Icons.home,
                                altura: alturaCampos,
                                tamanhoIcone: tamanhoIcone,
                                tamanhoIconeInterno: tamanhoIconeInterno,
                                fonteLabel: fonteLabel,
                              ),

                              SizedBox(height: espacamentoCampos,),
                              _campo(
                                titulo: 'E-mail',
                                icone: Icons.email,
                                altura: alturaCampos,
                                tamanhoIcone: tamanhoIcone,
                                tamanhoIconeInterno: tamanhoIconeInterno,
                                fonteLabel: fonteLabel,
                              ),

                              SizedBox(height: espacamentoCampos,),
                              _campo(
                                titulo: 'Confirmar E-mail',
                                icone: Icons.email,
                                altura: alturaCampos,
                                tamanhoIcone: tamanhoIcone,
                                tamanhoIconeInterno: tamanhoIconeInterno,
                                fonteLabel: fonteLabel,
                              ),

                              SizedBox(height: espacamentoCampos,),
                              _campo(
                                titulo: 'Senha',
                                icone: Icons.lock,
                                altura: alturaCampos,
                                tamanhoIcone: tamanhoIcone,
                                tamanhoIconeInterno: tamanhoIconeInterno,
                                fonteLabel: fonteLabel,
                              ),

                              SizedBox(height: espacamentoCampos,),
                              _campo(
                                titulo: 'Confirmar Senha',
                                icone: Icons.lock,
                                altura: alturaCampos,
                                tamanhoIcone: tamanhoIcone,
                                tamanhoIconeInterno: tamanhoIconeInterno,
                                fonteLabel: fonteLabel,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30,),

                        _botaoCadastrar(
                        largura: larguraBotao,
                        altura: alturaBotao,
                        fonte: fonteBotao,
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

  Widget _campo({
    required String titulo,
    required IconData icone,
    required double altura,
    required double tamanhoIcone,
    required double tamanhoIconeInterno,
    required double fonteLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 4),
          child: Text(
            titulo,
            style: GoogleFonts.montserratAlternates(
              color: const Color(0xFF68442E),
              fontWeight: FontWeight.w500,
              fontSize: fonteLabel,
            ),
          ),
        ),

        SizedBox(
          height: altura,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerLeft,

            children: [
              Positioned(
                left: tamanhoIcone / 2,
                right: 0,
                top: 0,
                bottom: 0,

                child: Container(
                  decoration: const inset_shadow.BoxDecoration(
                    color: Color.fromRGBO(192,128,129,0.15,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(80),),
                    boxShadow: [
                      inset_shadow.BoxShadow(
                        color: Color.fromARGB(60,0,0,0,),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                        inset: true,
                      )
                    ]
                  ),

                  child: TextField(

                    style: GoogleFonts.montserratAlternates(
                      color: const Color(0xFF68442E),
                      fontWeight: FontWeight.w500,
                    ),

                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.transparent,

                      contentPadding: const EdgeInsets.only(
                        left: 35,
                        right: 15,
                      ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(80),
                        borderSide: BorderSide.none,
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(80),
                        borderSide: const BorderSide(
                          color: Color(0xFF68442E),
                          width: 1.5,
                        ),
                      )
                    ),
                  ),
                ),
              ),

              Container(
                width: tamanhoIcone,
                height: tamanhoIcone,

                decoration: inset_shadow.BoxDecoration(
                  color: const Color(0xFFFAD3D5),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFC08081)
                        .withValues(alpha: 0.80),
                    width: 3,
                  ),
                  boxShadow: const[
                    inset_shadow.BoxShadow(
                      color: Color.fromARGB(50, 255, 255, 255),
                      blurRadius: 4,
                      offset: Offset(-2, -2),
                      inset: true,
                    ),

                    inset_shadow.BoxShadow(
                      color: Color.fromARGB(70, 105, 66, 67),
                      blurRadius: 5,
                      offset: Offset(3, 4),
                      inset: true,
                    ),
                  ],
                ),

                child: Icon(
                  icone,
                  color: const Color(0xFFC08081),
                  size: tamanhoIconeInterno,
                ),
              )
            ],
          ),
        )
      ],
    );
  }
  Widget _botaoCadastrar({
    required double largura,
    required double altura,
    required double fonte,
  }) {
    return Container(
      width: largura,
      height: altura,

      decoration:
          const inset_shadow.BoxDecoration(
        borderRadius:
            BorderRadius.all(
          Radius.circular(80),
        ),

        boxShadow: [
          inset_shadow.BoxShadow(
            color: Color.fromARGB(
              150,
              105,
              66,
              67,
            ),
            blurRadius: 8,
            offset: Offset(4, 5),
          ),
        ],
      ),

      child: Stack(
        fit: StackFit.expand,

        children: [

          TextButton(
            onPressed: () {
              // Futuramente você coloca a navegação
              // para a próxima tela aqui.
            },

            style: TextButton.styleFrom(
              backgroundColor:
                  const Color(0xFFC08081),

              foregroundColor: Colors.white,

              elevation: 0,

              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(80),
              ),
            ),

            child: Text(
              'Cadastrar',
              style:
                  GoogleFonts.montserratAlternates(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: fonte,
              ),
            ),
          ),

          Positioned(
            top: 1,
            left: largura / 8,
            right: largura / 8,

            child: Container(
              height: 2,

              decoration:
                  BoxDecoration(
                color:
                    Colors.white.withValues(
                  alpha: 0.60,
                ),

                borderRadius:
                    BorderRadius.circular(2),
              ),
            ),
          ),

          Positioned(
            bottom: 1,
            left: largura / 10,
            right: largura / 10,

            child: Container(
              height: 2,

              decoration:
                  BoxDecoration(
                color:
                    Colors.white.withValues(
                  alpha: 0.40,
                ),

                borderRadius:
                    BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
