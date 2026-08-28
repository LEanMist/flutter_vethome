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
            final alturaCampos = compacto ? 42 : 62;
            final tamanhoIcone = compacto ? 48 : 54;
            final tamanhoIconeInterno = compacto ? 26 : 30;
            final fonteLabel = compacto ? 14 : 17; 
            final larguraBotao = compacto? 54 : 62;
            final alturaBotao = compacto? 54 : 62;
            final fonteBotao = compacto? 16 : 18;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: compacto? 16 : 24, vertical: 20,),
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
                                alturaCampos,
                                tamanhoIcone,
                                tamanhoIconeInterno,
                                fonteLabel
                              ),

                              SizedBox(height: espacamentoCampos,)
                              _campo(
                                titulo: 'Data de Nascimento',
                                icone: Icons.calendar_month,
                                alturaCampos,
                                tamanhoIcone,
                                tamanhoIconeInterno,
                                fonteLabel
                              ),

                              SizedBox(height: espacamentoCampos,)
                              _campo(
                                titulo: 'Gênero/Sexo',
                                icone: Icons.wc,
                                alturaCampos,
                                tamanhoIcone,
                                tamanhoIconeInterno,
                                fonteLabel
                              ),

                              SizedBox(height: espacamentoCampos,)
                              _campo(
                                titulo: 'CPF',
                                icone: Icons.badge,
                                alturaCampos,
                                tamanhoIcone,
                                tamanhoIconeInterno,
                                fonteLabel
                              ),

                              SizedBox(height: espacamentoCampos,)
                              _campo(
                                titulo: 'Telefone/Celular',
                                icone: Icons.phone,
                                alturaCampos,
                                tamanhoIcone,
                                tamanhoIconeInterno,
                                fonteLabel
                              ),

                              SizedBox(height: espacamentoCampos,)
                              _campo(
                                titulo: 'Confirmar Telefone/Celular',
                                icone: Icons.phone,
                                alturaCampos,
                                tamanhoIcone,
                                tamanhoIconeInterno,
                                fonteLabel
                              ),

                              SizedBox(height: espacamentoCampos,)
                              _campo(
                                titulo: 'CEP',
                                icone: Icons.home,
                                alturaCampos,
                                tamanhoIcone,
                                tamanhoIconeInterno,
                                fonteLabel
                              ),

                              SizedBox(height: espacamentoCampos,)
                              _campo(
                                titulo: 'E-mail',
                                icone: Icons.email,
                                alturaCampos,
                                tamanhoIcone,
                                tamanhoIconeInterno,
                                fonteLabel
                              ),

                              SizedBox(height: espacamentoCampos,)
                              _campo(
                                titulo: 'Confirmar E-mail',
                                icone: Icons.email,
                                alturaCampos,
                                tamanhoIcone,
                                tamanhoIconeInterno,
                                fonteLabel
                              ),

                              SizedBox(height: espacamentoCampos,)
                              _campo(
                                titulo: 'Senha',
                                icone: Icons.lock,
                                alturaCampos,
                                tamanhoIcone,
                                tamanhoIconeInterno,
                                fonteLabel
                              ),

                              SizedBox(height: espacamentoCampos,)
                              _campo(
                                titulo: 'Confirmar Senha',
                                icone: Icons.lock,
                                alturaCampos,
                                tamanhoIcone,
                                tamanhoIconeInterno,
                                fonteLabel
                              ),
                            ],
                          ),
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
