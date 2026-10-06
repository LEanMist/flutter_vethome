import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_vethome/models/pet.dart';
import 'package:flutter_vethome/pages/carregamento.dart';
import 'package:flutter_vethome/repositories/pet_repository.dart';
import 'package:flutter_vethome/widgets/botao_cadastrar.dart';
import 'package:flutter_vethome/widgets/campo_cadastro.dart';
import 'package:flutter_vethome/widgets/pet_type_selector.dart';

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
  final repository = InMemoryPetRepository.instance;
  final nomeController = TextEditingController();
  final racaController = TextEditingController();
  final pesoController = TextEditingController();
  final dataController = TextEditingController();

  PetType? _tipo;
  PetGenero? _genero;
  DateTime? _dataNascimento;
  final Map<String, String> _errors = <String, String>{};

  @override
  void dispose() {
    nomeController.dispose();
    racaController.dispose();
    pesoController.dispose();
    dataController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF68442E),
        content: Text(message),
      ),
    );
  }

  void _cadastrar() {
    final pet = Pet(
      tipo: _tipo ?? PetType.outro,
      nome: nomeController.text,
      genero: _genero ?? PetGenero.macho,
      peso: double.tryParse(pesoController.text) ?? 0,
      dataNascimento: _dataNascimento ?? DateTime.now(),
      raca: racaController.text,
    );

    final errors = pet.errors;
    if (errors.isNotEmpty) {
      setState(() {
        _errors
          ..clear()
          ..addAll({
            for (final error in errors) error: error,
          });
      });
      _showError(errors.first);
      return;
    }

    try {
      repository.save(pet);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Carregamento(
            titulo: 'Pet cadastrado!',
            mensagem: '${pet.nome} foi cadastrado com sucesso.',
            destinoBuilder: widget.destinoBuilder,
          ),
        ),
      );
    } on ArgumentError catch (error) {
      _showError(error.message.toString());
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _dataNascimento = picked;
        dataController.text =
            '${picked.day}/${picked.month}/${picked.year}';
        _errors.remove('Data de nascimento não pode ser futura.');
      });
    }
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
                              PetTypeSelector(
                                value: _tipo,
                                onChanged: (tipo) => setState(() => _tipo = tipo),
                              ),

                              SizedBox(height: espacamentoCampos,),
                              CampoCadastro(
                                titulo: 'Nome do animal',
                                icone: Icons.pets,
                                altura: alturaCampos,
                                largura: larguraCampos,
                                tamanhoIcone: tamanhoIcone,
                                tamanhoIconeInterno: tamanhoIconeInterno,
                                fonteLabel: fonteLabel,
                                controller: nomeController,
                                errorText: _errors['Nome do animal é obrigatório.'],
                                onChanged: (_) => _errors.remove('Nome do animal é obrigatório.'),
                              ),

                              SizedBox(height: espacamentoCampos,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<PetGenero>(
                                      initialValue: _genero,
                                      decoration: const InputDecoration(
                                        labelText: 'Gênero/Sexo',
                                        border: OutlineInputBorder(),
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: PetGenero.macho,
                                          child: Text('Macho'),
                                        ),
                                        DropdownMenuItem(
                                          value: PetGenero.femea,
                                          child: Text('Fêmea'),
                                        ),
                                      ],
                                      onChanged: (genero) => setState(() => _genero = genero),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: CampoCadastro(
                                      titulo: 'Peso',
                                      icone: Icons.monitor_weight,
                                      altura: alturaCampos,
                                      largura: double.infinity,
                                      tamanhoIcone: tamanhoIcone,
                                      tamanhoIconeInterno:
                                          tamanhoIconeInterno,
                                      fonteLabel: fonteLabel,
                                      controller: pesoController,
                                      errorText: _errors['Peso deve ser maior que zero.'],
                                      onChanged: (_) => _errors.remove('Peso deve ser maior que zero.'),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: espacamentoCampos,),
                              CampoCadastro(
                                titulo: 'Data de nascimento',
                                icone: Icons.cake,
                                altura: alturaCampos,
                                largura: larguraCampos,
                                tamanhoIcone: tamanhoIcone,
                                tamanhoIconeInterno: tamanhoIconeInterno,
                                fonteLabel: fonteLabel,
                                controller: dataController,
                                errorText: _errors['Data de nascimento não pode ser futura.'],
                                onChanged: (_) => _errors.remove('Data de nascimento não pode ser futura.'),
                                onTap: () {
                                  _selectDate(context);
                                },
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
                                controller: racaController,
                                errorText: _errors['Raça é obrigatória.'],
                                onChanged: (_) => _errors.remove('Raça é obrigatória.'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30,),

                        BotaoCadastro(
                          largura: larguraBotao,
                          altura: alturaBotao,
                          fonte: fonteBotao,
                          onPressed: _cadastrar,
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
