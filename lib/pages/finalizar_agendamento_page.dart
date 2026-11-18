import 'package:flutter/material.dart';
import 'package:flutter_vethome/models/agendamento.dart';
import 'package:flutter_vethome/models/pet.dart';
import 'package:flutter_vethome/models/usuario.dart';
import 'package:flutter_vethome/repositories/agendamento_repository.dart';
import 'package:flutter_vethome/repositories/usuario_repository.dart';
import 'package:flutter_vethome/themes/vet_cores.dart';
import 'package:google_fonts/google_fonts.dart';

class FinalizarAgendamentoPage extends StatefulWidget {
	const FinalizarAgendamentoPage({
		super.key,
		required this.rascunho,
		required this.petNome,
		required this.petTipo,
		required this.convenio,
		this.usuarioRepository,
		this.agendamentoRepository,
	});

	final AgendamentoRascunho rascunho;
	final String petNome;
	final PetType petTipo;
	final ConvenioAgendamento convenio;
	final UsuarioRepository? usuarioRepository;
	final AgendamentoRepository? agendamentoRepository;

	@override
	State<FinalizarAgendamentoPage> createState() =>
			_FinalizarAgendamentoPageState();
}

class _FinalizarAgendamentoPageState extends State<FinalizarAgendamentoPage> {
	static const _horariosDisponiveis = [
		'12:00',
		'13:00',
		'14:00',
		'15:00',
		'16:00',
	];

	late final UsuarioRepository _usuarioRepository;
	late final AgendamentoRepository _agendamentoRepository;
	late DateTime _data;
	late String _horario;
	final _descricaoController = TextEditingController();
	Usuario? _usuario;
	String? _enderecoSelecionadoId;
	bool _salvando = false;

	@override
	void initState() {
		super.initState();
		_usuarioRepository =
				widget.usuarioRepository ?? InMemoryUsuarioRepository.instance;
		_agendamentoRepository =
				widget.agendamentoRepository ?? InMemoryAgendamentoRepository.instance;
		_usuario = _usuarioRepository.findById(widget.rascunho.usuarioId);
		_data = widget.rascunho.data;
		_horario = widget.rascunho.horario;
		if (_usuario != null) _enderecoSelecionadoId = 'principal';
	}

	@override
	void dispose() {
		_descricaoController.dispose();
		super.dispose();
	}

	List<_EnderecoOpcao> get _enderecos {
		final usuario = _usuario;
		if (usuario == null) return const [];

		final principal = [
			usuario.endereco,
			usuario.numero,
			if (usuario.complemento.trim().isNotEmpty) usuario.complemento,
			usuario.cidade,
			'CEP ${usuario.cep}',
		].where((parte) => parte.trim().isNotEmpty).join(', ');

		return [
			_EnderecoOpcao(
				id: 'principal',
				nome: 'Endereço principal',
				descricao: principal,
			),
			for (var index = 0; index < usuario.enderecosAdicionais.length; index++)
				_EnderecoOpcao(
					id: 'adicional-$index',
					nome: usuario.enderecosAdicionais[index].nome,
					descricao: usuario.enderecosAdicionais[index].enderecoCompleto,
				),
		];
	}

	String _nomeConvenio(ConvenioAgendamento convenio) => switch (convenio) {
		ConvenioAgendamento.petlove => 'PetLove',
		ConvenioAgendamento.doglife => 'Doglife',
		ConvenioAgendamento.particular => 'Particular',
	};

	String _formatarData(DateTime data) =>
			'${data.day.toString().padLeft(2, '0')}/'
			'${data.month.toString().padLeft(2, '0')}/${data.year}';

	Future<String?> _escolherHorario(DateTime data) {
		return showDialog<String>(
			context: context,
			builder: (context) => AlertDialog(
				backgroundColor: VetCores.rosaFundo,
				title: Text(
					'Horários para ${_formatarData(data)}',
					style: GoogleFonts.comfortaa(
						color: VetCores.marrom,
						fontWeight: FontWeight.bold,
					),
				),
				content: Column(
					mainAxisSize: MainAxisSize.min,
					children: [
						for (final horario in _horariosDisponiveis)
							ListTile(
								key: ValueKey('horario-$horario'),
								title: Text(
									horario,
									style: GoogleFonts.comfortaa(color: VetCores.marrom),
								),
								onTap: () => Navigator.of(context).pop(horario),
							),
					],
				),
			),
		);
	}

	Future<void> _selecionarData() async {
		final hoje = DateUtils.dateOnly(DateTime.now());
		final data = await showDatePicker(
			context: context,
			initialDate: _data.isBefore(hoje) ? hoje : _data,
			firstDate: hoje,
			lastDate: DateTime(hoje.year + 2, hoje.month, hoje.day),
		);
		if (!mounted || data == null) return;

		final horario = await _escolherHorario(data);
		if (!mounted || horario == null) return;

		setState(() {
			_data = DateUtils.dateOnly(data);
			_horario = horario;
		});
	}

	Future<void> _selecionarHorario() async {
		final horario = await _escolherHorario(_data);
		if (!mounted || horario == null) return;
		setState(() => _horario = horario);
	}

	Future<void> _adicionarEndereco() async {
		final usuario = _usuario;
		if (usuario == null) {
			_mostrarMensagem('Não foi possível carregar os dados do usuário.');
			return;
		}

		final endereco = await showDialog<EnderecoUsuario>(
			context: context,
			builder: (context) => const _NovoEnderecoDialog(),
		);
		if (!mounted || endereco == null) return;

		final enderecos = [...usuario.enderecosAdicionais, endereco];
		final atualizado = usuario.copyWith(enderecosAdicionais: enderecos);
		try {
			_usuarioRepository.save(atualizado);
			final usuarioSalvo = atualizado.id == null
					? atualizado
					: _usuarioRepository.findById(atualizado.id!) ?? atualizado;
			setState(() {
				_usuario = usuarioSalvo;
				_enderecoSelecionadoId = 'adicional-${enderecos.length - 1}';
			});
		} catch (error) {
			_mostrarMensagem('Não foi possível salvar o endereço: $error');
		}
	}

	Future<void> _salvarAgendamento() async {
		if (_salvando) return;
		final enderecos = _enderecos;
		final enderecoSelecionado = enderecos
				.where((endereco) => endereco.id == _enderecoSelecionadoId)
				.firstOrNull;
		if (enderecoSelecionado == null || enderecoSelecionado.descricao.isEmpty) {
			_mostrarMensagem('Selecione um endereço para o atendimento.');
			return;
		}

		final rascunho = AgendamentoRascunho(
			usuarioId: widget.rascunho.usuarioId,
			petId: widget.rascunho.petId,
			data: _data,
			horario: _horario,
			servicos: widget.rascunho.servicos,
		);
		final agendamento = rascunho.finalizar(
			convenio: widget.convenio,
			endereco: enderecoSelecionado.descricao,
			descricao: _descricaoController.text.trim(),
		);
		if (agendamento.errors.isNotEmpty) {
			_mostrarMensagem(agendamento.errors.first);
			return;
		}

		setState(() => _salvando = true);
		try {
			final salvo = await _agendamentoRepository.save(agendamento);
			if (mounted) Navigator.of(context).pop(salvo);
		} catch (error) {
			if (mounted) _mostrarMensagem('Não foi possível salvar: $error');
		} finally {
			if (mounted) setState(() => _salvando = false);
		}
	}

	void _mostrarMensagem(String mensagem) {
		ScaffoldMessenger.of(
			context,
		).showSnackBar(SnackBar(content: Text(mensagem)));
	}

	Widget _campoResumo({
		required IconData icone,
		required String titulo,
		required String valor,
		VoidCallback? onTap,
	}) {
		return Padding(
			padding: const EdgeInsets.only(bottom: 10),
			child: Material(
				color: VetCores.rosaEscuro.withValues(alpha: 0.18),
				borderRadius: BorderRadius.circular(12),
				child: InkWell(
					key: ValueKey('resumo-$titulo'),
					onTap: onTap,
					borderRadius: BorderRadius.circular(12),
					child: Padding(
						padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
						child: Row(
							children: [
								Icon(icone, color: VetCores.marrom),
								const SizedBox(width: 12),
								Expanded(
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Text(
												titulo,
												style: GoogleFonts.montserratAlternates(
													color: VetCores.marrom,
													fontSize: 12,
												),
											),
											const SizedBox(height: 3),
											Text(
												valor,
												maxLines: 2,
												overflow: TextOverflow.ellipsis,
												style: GoogleFonts.montserratAlternates(
													color: VetCores.marrom,
													fontWeight: FontWeight.bold,
												),
											),
										],
									),
								),
								if (onTap != null)
									const Icon(Icons.chevron_right_rounded, color: VetCores.marrom),
							],
						),
					),
				),
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		final compacto = MediaQuery.sizeOf(context).width < 500;
		final servicos = widget.rascunho.servicos.map((servico) => servico.nome);

		return Scaffold(
			backgroundColor: VetCores.rosaFundo,
			body: Column(
				children: [
					Container(
						width: double.infinity,
						height: compacto ? 116 : 128,
						padding: EdgeInsets.fromLTRB(6, compacto ? 18 : 24, 8, 12),
						decoration: const BoxDecoration(
							color: VetCores.rosaEscuro,
							borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
						),
						child: Row(
							children: [
								IconButton(
									tooltip: 'Voltar para convênio',
									onPressed: () => Navigator.of(context).pop(),
									icon: const Icon(Icons.arrow_back),
									color: VetCores.branco,
								),
								Expanded(
									child: Text(
										'Finalizar agendamento',
										textAlign: TextAlign.center,
										maxLines: 1,
										overflow: TextOverflow.ellipsis,
										style: GoogleFonts.comfortaa(
											color: VetCores.branco,
											fontSize: compacto ? 24 : 30,
											fontWeight: FontWeight.bold,
										),
									),
								),
								const SizedBox(width: 48),
							],
						),
					),
					Expanded(
						child: ListView(
							padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
							children: [
								Text(
									'Revisar agendamento',
									style: GoogleFonts.montserratAlternates(
										color: VetCores.marrom,
										fontSize: 17,
										fontWeight: FontWeight.bold,
									),
								),
								const SizedBox(height: 10),
								_campoResumo(
									icone: Icons.medical_services_outlined,
									titulo: 'Serviços',
									valor: servicos.join(', '),
								),
								_campoResumo(
									icone: Icons.health_and_safety_outlined,
									titulo: 'Convênio',
									valor: _nomeConvenio(widget.convenio),
								),
								Row(
									children: [
										Expanded(
											child: _campoResumo(
												icone: Icons.calendar_month_outlined,
												titulo: 'Data',
												valor: _formatarData(_data),
												onTap: _selecionarData,
											),
										),
										const SizedBox(width: 10),
										Expanded(
											child: _campoResumo(
												icone: Icons.access_time_rounded,
												titulo: 'Horário',
												valor: _horario,
												onTap: _selecionarHorario,
											),
										),
									],
								),
								const SizedBox(height: 4),
								Text(
									'Endereço do atendimento',
									style: GoogleFonts.montserratAlternates(
										color: VetCores.marrom,
										fontSize: 17,
										fontWeight: FontWeight.bold,
									),
								),
								const SizedBox(height: 8),
								if (_enderecos.isEmpty)
									Padding(
										padding: const EdgeInsets.only(bottom: 10),
										child: Text(
											'Não há endereço principal disponível para este usuário.',
											style: GoogleFonts.montserratAlternates(
												color: VetCores.marrom,
											),
										),
									),
								for (final endereco in _enderecos)
									Padding(
										padding: const EdgeInsets.only(bottom: 8),
										child: Material(
											color: _enderecoSelecionadoId == endereco.id
													? VetCores.rosaEscuro.withValues(alpha: 0.24)
													: VetCores.rosaCard,
											borderRadius: BorderRadius.circular(10),
											child: InkWell(
												key: ValueKey('endereco-${endereco.id}'),
												borderRadius: BorderRadius.circular(10),
												onTap: () => setState(
													() => _enderecoSelecionadoId = endereco.id,
												),
												child: Padding(
													padding: const EdgeInsets.all(12),
													child: Row(
														children: [
															Icon(
																_enderecoSelecionadoId == endereco.id
																		? Icons.radio_button_checked
																		: Icons.radio_button_unchecked,
																color: VetCores.marrom,
															),
															const SizedBox(width: 10),
															Expanded(
																child: Column(
																	crossAxisAlignment: CrossAxisAlignment.start,
																	children: [
																		Text(
																			endereco.nome,
																			style: GoogleFonts.montserratAlternates(
																				color: VetCores.marrom,
																				fontWeight: FontWeight.bold,
																			),
																		),
																		Text(
																			endereco.descricao,
																			style: GoogleFonts.montserratAlternates(
																				color: VetCores.marrom,
																				fontSize: 12,
																			),
																		),
																	],
																),
															),
														],
													),
												),
											),
										),
									),
								Align(
									alignment: Alignment.centerLeft,
									child: OutlinedButton.icon(
										key: const ValueKey('adicionar-endereco'),
										onPressed: _adicionarEndereco,
										icon: const Icon(Icons.add_location_alt_outlined),
										label: Text(
											'Adicionar mais endereço',
											style: GoogleFonts.montserratAlternates(),
										),
										style: OutlinedButton.styleFrom(
											foregroundColor: VetCores.marrom,
											side: const BorderSide(color: VetCores.rosaEscuro),
										),
									),
								),
								const SizedBox(height: 14),
								Text(
									'Descrição para a veterinária',
									style: GoogleFonts.montserratAlternates(
										color: VetCores.marrom,
										fontWeight: FontWeight.bold,
									),
								),
								const SizedBox(height: 6),
								TextField(
									key: const ValueKey('descricao-agendamento'),
									controller: _descricaoController,
									minLines: 3,
									maxLines: 5,
									textCapitalization: TextCapitalization.sentences,
									decoration: InputDecoration(
										hintText: 'Adicione informações importantes',
										filled: true,
										fillColor: VetCores.rosaEscuro.withValues(alpha: 0.35),
										border: OutlineInputBorder(
											borderRadius: BorderRadius.circular(10),
											borderSide: BorderSide.none,
										),
									),
								),
							],
						),
					),
				],
			),
			bottomNavigationBar: SafeArea(
				top: false,
				child: Padding(
					padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
					child: SizedBox(
						height: 52,
						child: ElevatedButton(
							key: const ValueKey('salvar-agendamento'),
							onPressed: _salvando ? null : _salvarAgendamento,
							style: ElevatedButton.styleFrom(
								backgroundColor: VetCores.marrom,
								foregroundColor: VetCores.branco,
								shape: RoundedRectangleBorder(
									borderRadius: BorderRadius.circular(28),
								),
							),
							child: Text(
								_salvando ? 'Salvando...' : 'Salvar agendamento',
								style: GoogleFonts.comfortaa(
									fontSize: 16,
									fontWeight: FontWeight.bold,
								),
							),
						),
					),
				),
			),
		);
	}
}

class _EnderecoOpcao {
	const _EnderecoOpcao({
		required this.id,
		required this.nome,
		required this.descricao,
	});

	final String id;
	final String nome;
	final String descricao;
}

class _NovoEnderecoDialog extends StatefulWidget {
	const _NovoEnderecoDialog();

	@override
	State<_NovoEnderecoDialog> createState() => _NovoEnderecoDialogState();
}

class _NovoEnderecoDialogState extends State<_NovoEnderecoDialog> {
	final _formKey = GlobalKey<FormState>();
	final _nomeController = TextEditingController();
	final _cepController = TextEditingController();
	final _logradouroController = TextEditingController();
	final _numeroController = TextEditingController();
	final _complementoController = TextEditingController();
	final _cidadeController = TextEditingController();

	@override
	void dispose() {
		_nomeController.dispose();
		_cepController.dispose();
		_logradouroController.dispose();
		_numeroController.dispose();
		_complementoController.dispose();
		_cidadeController.dispose();
		super.dispose();
	}

	String? _obrigatorio(String? valor) =>
			valor == null || valor.trim().isEmpty ? 'Campo obrigatório' : null;

	void _salvar() {
		if (!_formKey.currentState!.validate()) return;
		Navigator.of(context).pop(
			EnderecoUsuario(
				nome: _nomeController.text.trim(),
				cep: _cepController.text.trim(),
				logradouro: _logradouroController.text.trim(),
				numero: _numeroController.text.trim(),
				complemento: _complementoController.text.trim(),
				cidade: _cidadeController.text.trim(),
			),
		);
	}

	Widget _campo(
		String label,
		TextEditingController controller, {
		String? Function(String?)? validator,
		TextInputType? keyboardType,
		bool obrigatorio = true,
	}) {
		return Padding(
			padding: const EdgeInsets.only(bottom: 10),
			child: TextFormField(
				key: ValueKey('novo-endereco-${label.toLowerCase()}'),
				controller: controller,
				validator: obrigatorio ? (validator ?? _obrigatorio) : null,
				keyboardType: keyboardType,
				textCapitalization: TextCapitalization.words,
				decoration: InputDecoration(
					labelText: label,
					filled: true,
					fillColor: VetCores.rosaEscuro.withValues(alpha: 0.18),
					border: OutlineInputBorder(
						borderRadius: BorderRadius.circular(8),
						borderSide: BorderSide.none,
					),
				),
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		return AlertDialog(
			backgroundColor: VetCores.rosaFundo,
			title: Text(
				'Adicionar endereço',
				style: GoogleFonts.comfortaa(
					color: VetCores.marrom,
					fontWeight: FontWeight.bold,
				),
			),
			content: SizedBox(
				width: 380,
				child: SingleChildScrollView(
					child: Form(
						key: _formKey,
						child: Column(
							mainAxisSize: MainAxisSize.min,
							children: [
								_campo('Nome do endereço', _nomeController),
								_campo(
									'CEP',
									_cepController,
									keyboardType: TextInputType.number,
									validator: (valor) {
										final numeros = valor?.replaceAll(RegExp(r'\D'), '') ?? '';
										return numeros.length == 8 ? null : 'Informe um CEP válido';
									},
								),
								_campo('Logradouro', _logradouroController),
								_campo('Número', _numeroController),
								_campo(
									'Complemento',
									_complementoController,
									obrigatorio: false,
								),
								_campo('Cidade', _cidadeController),
							],
						),
					),
				),
			),
			actions: [
				TextButton(
					onPressed: () => Navigator.of(context).pop(),
					child: Text('Cancelar', style: GoogleFonts.comfortaa()),
				),
				ElevatedButton(
					key: const ValueKey('salvar-novo-endereco'),
					onPressed: _salvar,
					style: ElevatedButton.styleFrom(
						backgroundColor: VetCores.marrom,
						foregroundColor: VetCores.branco,
					),
					child: Text('Salvar endereço', style: GoogleFonts.comfortaa()),
				),
			],
		);
	}
}

class _SeletorHorarioDialog extends StatelessWidget {
	const _SeletorHorarioDialog({required this.data});

	static const _horarios = ['12:00', '13:00', '14:00', '15:00', '16:00'];

	final DateTime data;

	@override
	Widget build(BuildContext context) {
		final dataFormatada =
				'${data.day.toString().padLeft(2, '0')}/'
				'${data.month.toString().padLeft(2, '0')}/${data.year}';
		return AlertDialog(
			backgroundColor: VetCores.rosaFundo,
			title: Text(
				'Horários para $dataFormatada',
				style: GoogleFonts.comfortaa(
					color: VetCores.marrom,
					fontWeight: FontWeight.bold,
				),
			),
			content: Column(
				mainAxisSize: MainAxisSize.min,
				children: [
					for (final horario in _horarios)
						ListTile(
							key: ValueKey('horario-$horario'),
							title: Text(horario),
							onTap: () => Navigator.of(context).pop(horario),
						),
				],
			),
		);
	}
}

