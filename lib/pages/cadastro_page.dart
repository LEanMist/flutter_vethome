import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_vethome/pages/carregamento.dart';
import 'package:flutter_vethome/pages/escolha_pet_page.dart';
import 'package:flutter_vethome/widgets/campo_cadastro.dart';
import 'package:flutter_vethome/widgets/botao_cadastrar.dart';

class InformacoesCadastroPage extends StatefulWidget {
  const InformacoesCadastroPage({super.key});

  @override
  State<InformacoesCadastroPage> createState() => _InformacoesCadastroPageState();
}

class _InformacoesCadastroPageState extends State<InformacoesCadastroPage> {
  void escolhapet(){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Carregamento(
          destinoBuilder: (context) => const EscolhaPetPage(),
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
            final double alturaCampos = compacto ? 50 : 57;
            final double larguraCampos = compacto ? 400 : 500;
            final double tamanhoIcone = compacto ? 52 : 58;
            final double tamanhoIconeInterno = compacto ? 28 : 35;
            final double fonteLabel = compacto ? 14 : 17; 
            final double larguraBotao = compacto? 150 : 180;
            final double alturaBotao = compacto? 54 : 62;
            final double fonteBotao = compacto? 16 : 18;

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
                                titulo: 'Nome Completo',
                                icone: Icons.person,
                                altura: alturaCampos,
                                largura: larguraCampos,
                                tamanhoIcone: tamanhoIcone,
                                tamanhoIconeInterno: tamanhoIconeInterno,
                                fonteLabel: fonteLabel,
                              ),

                              SizedBox(height: espacamentoCampos,),
                              CampoCadastro(
                                titulo: 'Data de Nascimento',
                                icone: Icons.calendar_month,
                                altura: alturaCampos,
                                largura: larguraCampos,
                                tamanhoIcone: tamanhoIcone,
                                tamanhoIconeInterno: tamanhoIconeInterno,
                                fonteLabel: fonteLabel,
                              ),

                              SizedBox(height: espacamentoCampos,),
                              CampoCadastro(
                                titulo: 'Gênero/Sexo',
                                icone: Icons.wc,
                                altura: alturaCampos,
                                largura: larguraCampos,
                                tamanhoIcone: tamanhoIcone,
                                tamanhoIconeInterno: tamanhoIconeInterno,
                                fonteLabel: fonteLabel,
                              ),

                              SizedBox(height: espacamentoCampos,),
                              CampoCadastro(
                                titulo: 'CPF',
                                icone: Icons.badge,
                                altura: alturaCampos,
                                largura: larguraCampos,
                                tamanhoIcone: tamanhoIcone,
                                tamanhoIconeInterno: tamanhoIconeInterno,
                                fonteLabel: fonteLabel,
                              ),

                              SizedBox(height: espacamentoCampos,),
                              CampoCadastro(
                                titulo: 'Telefone/Celular',
                                icone: Icons.phone,
                                altura: alturaCampos,
                                largura: larguraCampos,
                                tamanhoIcone: tamanhoIcone,
                                tamanhoIconeInterno: tamanhoIconeInterno,
                                fonteLabel: fonteLabel,
                              ),

                              SizedBox(height: espacamentoCampos,),
                              CampoCadastro(
                                titulo: 'Confirmar Telefone/Celular',
                                icone: Icons.phone,
                                altura: alturaCampos,
                                largura: larguraCampos,
                                tamanhoIcone: tamanhoIcone,
                                tamanhoIconeInterno: tamanhoIconeInterno,
                                fonteLabel: fonteLabel,
                              ),

                              SizedBox(height: espacamentoCampos,),
                              CampoCadastro(
                                titulo: 'CEP',
                                icone: Icons.home,
                                altura: alturaCampos,
                                largura: larguraCampos,
                                tamanhoIcone: tamanhoIcone,
                                tamanhoIconeInterno: tamanhoIconeInterno,
                                fonteLabel: fonteLabel,
                              ),

                              SizedBox(height: espacamentoCampos,),
                              CampoCadastro(
                                titulo: 'Endereço',
                                icone: Icons.home,
                                altura: alturaCampos,
                                largura: larguraCampos,
                                tamanhoIcone: tamanhoIcone,
                                tamanhoIconeInterno: tamanhoIconeInterno,
                                fonteLabel: fonteLabel,
                              ),

                              SizedBox(height: espacamentoCampos,),
                              CampoCadastro(
                                titulo: 'Numero',
                                icone: Icons.numbers,
                                altura: alturaCampos,
                                largura: larguraCampos,
                                tamanhoIcone: tamanhoIcone,
                                tamanhoIconeInterno: tamanhoIconeInterno,
                                fonteLabel: fonteLabel,
                              ),

                              SizedBox(height: espacamentoCampos,),
                              CampoCadastro(
                                titulo: 'Cidade',
                                icone: Icons.location_city,
                                altura: alturaCampos,
                                largura: larguraCampos,
                                tamanhoIcone: tamanhoIcone,
                                tamanhoIconeInterno: tamanhoIconeInterno,
                                fonteLabel: fonteLabel,
                              ),

                              SizedBox(height: espacamentoCampos,),
                              CampoCadastro(
                                titulo: 'Complemento',
                                icone: Icons.home,
                                altura: alturaCampos,
                                largura: larguraCampos,
                                tamanhoIcone: tamanhoIcone,
                                tamanhoIconeInterno: tamanhoIconeInterno,
                                fonteLabel: fonteLabel,
                              ),


                              SizedBox(height: espacamentoCampos,),
                              CampoCadastro(
                                titulo: 'E-mail',
                                icone: Icons.email,
                                altura: alturaCampos,
                                largura: larguraCampos,
                                tamanhoIcone: tamanhoIcone,
                                tamanhoIconeInterno: tamanhoIconeInterno,
                                fonteLabel: fonteLabel,
                              ),

                              SizedBox(height: espacamentoCampos,),
                              CampoCadastro(
                                titulo: 'Confirmar E-mail',
                                icone: Icons.email,
                                altura: alturaCampos,
                                largura: larguraCampos,
                                tamanhoIcone: tamanhoIcone,
                                tamanhoIconeInterno: tamanhoIconeInterno,
                                fonteLabel: fonteLabel,
                              ),

                              SizedBox(height: espacamentoCampos,),
                              CampoCadastro(
                                titulo: 'Senha',
                                icone: Icons.lock,
                                altura: alturaCampos,
                                largura: larguraCampos,
                                tamanhoIcone: tamanhoIcone,
                                tamanhoIconeInterno: tamanhoIconeInterno,
                                fonteLabel: fonteLabel,
                              ),

                              SizedBox(height: espacamentoCampos,),
                              CampoCadastro(
                                titulo: 'Confirmar Senha',
                                icone: Icons.lock,
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
                        onPressed: escolhapet,
                      ),
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
