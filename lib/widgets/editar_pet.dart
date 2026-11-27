import 'package:flutter/material.dart';
import 'package:flutter_vethome/models/pet.dart';
import 'package:flutter_vethome/themes/vet_cores.dart';
import 'package:flutter_vethome/widgets/campo_cadastro.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_vethome/widgets/botao_estilizado.dart';

class EditarPet extends StatefulWidget {
  const EditarPet({super.key, required this.pet});

  final Pet pet;
  @override
  State<EditarPet> createState() => _EditarPetState();
}

class _EditarPetState extends State<EditarPet> {
  late final TextEditingController _nome;
  late final TextEditingController _genero;
  late final TextEditingController _peso;
  late final TextEditingController _data;
  late final TextEditingController _raca;
  late PetGenero _generoSelecionado;
  late DateTime _dataNascimento;
  String? _erro;

  String _formatarData(DateTime data) =>
      '${data.day.toString().padLeft(2, '0')}/'
      '${data.month.toString().padLeft(2, '0')}/${data.year}';

  String _nomeGenero(PetGenero genero) =>
      genero == PetGenero.macho ? 'Macho' : 'Fêmea';

  @override
  void initState() {
    super.initState();
    final pet = widget.pet;
    _generoSelecionado = pet.genero;
    _dataNascimento = pet.dataNascimento;
    _nome = TextEditingController(text: pet.nome);
    _genero = TextEditingController(text: _nomeGenero(pet.genero));
    _peso = TextEditingController(text: pet.peso.toString());
    _data = TextEditingController(text: _formatarData(pet.dataNascimento));
    _raca = TextEditingController(text: pet.raca);
  }

  @override
  void dispose() {
    _nome.dispose();
    _genero.dispose();
    _peso.dispose();
    _data.dispose();
    _raca.dispose();
    super.dispose();
  }

  Future<void> _selecionarGenero() async {
    final genero = await showModalBottomSheet<PetGenero>(
      context: context,
      backgroundColor: VetCores.rosaFundo,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Selecione o gênero do pet'),
            ),
            for (final opcao in PetGenero.values)
              ListTile(
                title: Text(_nomeGenero(opcao)),
                trailing: _generoSelecionado == opcao
                    ? const Icon(Icons.check, color: VetCores.marrom)
                    : null,
                onTap: () => Navigator.pop(context, opcao),
              ),
          ],
        ),
      ),
    );
    if (!mounted || genero == null) return;
    setState(() {
      _generoSelecionado = genero;
      _genero.text = _nomeGenero(genero);
    });
  }

  Future<void> _selecionarData() async {
    final hoje = DateTime.now();
    final data = await showDatePicker(
      context: context,
      initialDate: _dataNascimento.isAfter(hoje) ? hoje : _dataNascimento,
      firstDate: DateTime(1900),
      lastDate: hoje,
    );
    if (!mounted || data == null) return;
    setState(() {
      _dataNascimento = data;
      _data.text = _formatarData(data);
    });
  }

  void _salvar() {
    final peso = double.tryParse(_peso.text.trim().replaceAll(',', '.'));
    if (peso == null || !peso.isFinite || peso <= 0) {
      setState(() => _erro = 'Informe um peso válido maior que zero.');
      return;
    }
    final pet = widget.pet.copyWith(
      nome: _nome.text.trim(),
      genero: _generoSelecionado,
      peso: peso,
      dataNascimento: _dataNascimento,
      raca: _raca.text.trim(),
    );
    if (pet.errors.isNotEmpty) {
      setState(() => _erro = pet.errors.first);
      return;
    }
    Navigator.of(context).pop(pet);
  }

  Widget _campo(
    String titulo,
    TextEditingController controller,
    IconData icone, {
    required bool compacto,
    VoidCallback? onTap,
    TextInputType? keyboardType,
    double? tamanhoIcone,
    double? tamanhoFonte,
    bool linhaUnica = false,
  }) {
    return CampoCadastro(
      titulo: titulo,
      controller: controller,
      icone: icone,
      altura: compacto ? 55 : 55,
      largura: double.infinity,
      tamanhoIcone: tamanhoIcone ?? 55,
      tamanhoIconeInterno: compacto ? 26 : 27,
      fonteLabel: compacto ? 14 : 14,
      tamanhoFonteValor: tamanhoFonte ?? (compacto ? 15 : 14),
      keyboardType: keyboardType,
      onTap: onTap,
      linhaUnica: linhaUnica,
      paddingTexto: tamanhoIcone == null
          ? null
          : EdgeInsets.only(left: tamanhoIcone + 4, right: 4),
      textCapitalization: TextCapitalization.sentences,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tipo = switch (widget.pet.tipo) {
      PetType.cachorro => 'Cachorro(a)',
      PetType.gato => 'Gato(a)',
      PetType.outro => 'animal',
    };
    return LayoutBuilder(
      builder: (context, constraints) {
        final compacto =
            constraints.maxWidth < 500 || constraints.maxHeight < 700;
        final double larguraCampo = compacto ? 300 : 330;
        final double alturaCampo = compacto ? 350 : 400;
        return AlertDialog(
          backgroundColor: VetCores.rosaCard2,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          content: SizedBox(
            width: larguraCampo,
            height: alturaCampo,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _campo(
                    'Nome do $tipo',
                    _nome,
                    Icons.person,
                    compacto: compacto,
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final tamanhoIcone = constraints.maxWidth < 500
                          ? 55.0
                          : 50.0;
                      final tamanhoFonte = constraints.maxWidth < 260
                          ? 15.0
                          : 15.0;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 6,
                            child: _campo(
                              'Gênero/Sexo',
                              _genero,
                              Icons.wc_rounded,
                              compacto: compacto,
                              tamanhoIcone: tamanhoIcone,
                              tamanhoFonte: tamanhoFonte,
                              linhaUnica: true,
                              onTap: _selecionarGenero,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 5,
                            child: _campo(
                              'Peso',
                              _peso,
                              Icons.monitor_weight_outlined,
                              compacto: compacto,
                              tamanhoIcone: tamanhoIcone,
                              tamanhoFonte: tamanhoFonte,
                              linhaUnica: true,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _campo(
                    'Data de Nascimento',
                    _data,
                    Icons.cake_outlined,
                    compacto: compacto,
                    onTap: _selecionarData,
                  ),
                  const SizedBox(height: 12),
                  _campo('Raça', _raca, Icons.pets_rounded, compacto: compacto),
                  if (_erro != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        _erro!,
                        style: const TextStyle(color: VetCores.vermelhoEscuro),
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: BotaoEstilizado(
                    texto: 'Excluir',
                    largura: 125,
                    altura: 49,
                    tamanhoFonte: 16,
                    corFundo: VetCores.rosaCard2,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: ElevatedButton(
                    onPressed: _salvar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: VetCores.marrom,
                      foregroundColor: VetCores.branco,
                    ),
                    child: Text('Salvar', style: GoogleFonts.comfortaa()),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
