import 'package:flutter/material.dart';
import '../core/utils/form_fields.dart';
import '../core/utils/formatters.dart';
import '../data/vet_repository.dart';
import '../models/pet_model.dart';
import '../models/vet_models.dart';
import '../theme/vet_colors.dart';
import '../theme/vet_tones.dart';
import '../widgets.dart';
import '../widgets/demo_badge.dart';
import '../widgets/pet_summary.dart';
import '../widgets/status_chip.dart';
import '../widgets/vet/vet_card.dart';
import '../widgets/vet/vet_page_scaffold.dart';

const _blockedVaccineMessage =
    'Armazenamento local bloqueado. Nenhuma alteração na vacina foi realizada.';
const _clearingVaccineMessage =
    'A alteração na carteira foi bloqueada enquanto os dados locais estavam '
    'sendo limpos. Nenhuma alteração foi realizada.';

class VacinacaoPage extends StatefulWidget {
  const VacinacaoPage({required this.pet, super.key});
  final PetModel pet;
  @override
  State<VacinacaoPage> createState() => _VacinacaoPageState();
}

class _VacinacaoPageState extends State<VacinacaoPage> {
  bool _saving = false;

  Future<void> _edit([Vacina? vaccine]) async {
    if (_saving) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: VetColors.pink,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _VaccineEditor(
        vaccine: vaccine,
        onSave: (value) =>
            _persist(() => VetRepository.saveVaccine(widget.pet.id, value)),
      ),
    );
  }

  Future<void> _delete(Vacina vaccine) async {
    if (_saving) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: VetColors.pink,
        title: const Text('Excluir vacina?'),
        content: Text('Remover ${vaccine.nome} da carteira deste pet?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted || _saving) return;
    try {
      await _persist(
        () => VetRepository.removeVaccine(widget.pet.id, vaccine.id!),
      );
    } on PersistenceClearingException {
      if (!mounted) return;
      _showPersistenceMessage(_clearingVaccineMessage);
    } on PersistenceBlockedException {
      if (!mounted) return;
      _showPersistenceMessage(_blockedVaccineMessage);
    }
  }

  void _showPersistenceMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Semantics(liveRegion: true, child: Text(message))),
      );
  }

  Future<void> _persist(VoidCallback update) async {
    update();
    setState(() => _saving = true);
    final saved = await VetRepository.flush();
    if (!mounted) return;
    setState(() => _saving = false);
    if (!saved) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Alteração na carteira feita nesta sessão. Não foi possível salvar localmente.',
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pet = VetRepository.petById(widget.pet.id) ?? widget.pet;
    final vaccines = VetRepository.vacinas(pet.id);
    final demo = VetRepository.usesDemoVaccines(pet.id);
    return VetPageScaffold(
      title: 'Carteira de vacinação',
      titleSize: 23,
      pet: pet,
      contentMaxWidth: 1120,
      children: [
        PetSummary(pet: pet, size: PetSummarySize.medium),
        VetCard(
          flat: true,
          color: VetColors.rose.withValues(alpha: .14),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                contagemVacinas(vaccines),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (demo) ...[const SizedBox(height: 6), const DemoBadge()],
              const SizedBox(height: 6),
              const Text(
                'Situação baseada nas datas informadas.',
                style: TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _saving ? null : () => _edit(),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Adicionar vacina'),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final desktop = constraints.maxWidth >= 900;
            final width = desktop
                ? (constraints.maxWidth - 16) / 2
                : constraints.maxWidth;
            return Wrap(
              key: ValueKey(
                desktop ? 'vaccines-desktop-grid' : 'vaccines-mobile-list',
              ),
              spacing: 16,
              runSpacing: 12,
              children: [
                for (final vaccine in vaccines)
                  SizedBox(
                    width: width,
                    child: _VacinaCard(
                      vaccine,
                      enabled: !_saving,
                      onEdit: demo ? null : () => _edit(vaccine),
                      onDelete: demo ? null : () => _delete(vaccine),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _VaccineEditor extends StatefulWidget {
  const _VaccineEditor({required this.onSave, this.vaccine});
  final Future<void> Function(Vacina) onSave;
  final Vacina? vaccine;
  @override
  State<_VaccineEditor> createState() => _VaccineEditorState();
}

class _VaccineEditorState extends State<_VaccineEditor> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.vaccine?.nome ?? '');
  late final _applied = TextEditingController(
    text: widget.vaccine == null ? '' : fmtData(widget.vaccine!.aplicada),
  );
  late final _next = TextEditingController(
    text: widget.vaccine?.proxima == null
        ? ''
        : fmtData(widget.vaccine!.proxima!),
  );
  bool _saving = false;
  bool _blocked = false;
  bool _clearing = false;
  @override
  void dispose() {
    _name.dispose();
    _applied.dispose();
    _next.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _blocked = false;
      _clearing = false;
    });
    try {
      await widget.onSave(
        Vacina(
          id: widget.vaccine?.id,
          nome: _name.text,
          aplicada: parseCalendarDate(_applied.text)!,
          proxima: _next.text.isEmpty ? null : parseCalendarDate(_next.text),
        ),
      );
      if (mounted && ModalRoute.of(context)?.isCurrent == true) {
        Navigator.pop(context);
      }
    } on PersistenceBlockedException {
      if (mounted) setState(() => _blocked = true);
    } on PersistenceClearingException {
      if (mounted) setState(() => _clearing = true);
    } on FormatException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.vaccine == null ? 'Adicionar vacina' : 'Editar vacina',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              VHField(
                'Nome da vacina',
                Icons.vaccines_outlined,
                compact: true,
                controller: _name,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Informe o nome da vacina.'
                    : null,
              ),
              const SizedBox(height: 12),
              VHField(
                'Data aplicada',
                Icons.calendar_today_outlined,
                compact: true,
                controller: _applied,
                keyboardType: TextInputType.number,
                inputFormatters: const [DigitsMask('##/##/####')],
                validator: (v) => parseBirthDate(v ?? '') == null
                    ? 'Informe uma data válida até hoje.'
                    : null,
              ),
              const SizedBox(height: 12),
              VHField(
                'Próxima dose (opcional)',
                Icons.event_outlined,
                compact: true,
                controller: _next,
                keyboardType: TextInputType.number,
                inputFormatters: const [DigitsMask('##/##/####')],
                validator: (v) {
                  if (v == null || v.isEmpty) return null;
                  final next = parseCalendarDate(v),
                      applied = parseCalendarDate(_applied.text);
                  return next == null ||
                          (applied != null && next.isBefore(applied))
                      ? 'Confira a data da próxima dose.'
                      : null;
                },
              ),
              if (_blocked || _clearing) ...[
                const SizedBox(height: 12),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    _clearing
                        ? _clearingVaccineMessage
                        : _blockedVaccineMessage,
                    key: ValueKey(
                      _clearing
                          ? 'vaccine-storage-clearing-message'
                          : 'vaccine-storage-blocked-message',
                    ),
                    style: TextStyle(
                      color: VetColors.brown,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Salvando…' : 'Salvar vacina'),
              ),
              TextButton(
                onPressed: _saving ? null : () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _VacinaCard extends StatelessWidget {
  const _VacinaCard(
    this.vaccine, {
    required this.enabled,
    this.onEdit,
    this.onDelete,
  });
  final Vacina vaccine;
  final bool enabled;
  final VoidCallback? onEdit, onDelete;
  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (vaccine.status) {
      VacinaStatus.emDia => (VetTones.success, 'Em dia'),
      VacinaStatus.vencendo => (VetTones.warning, 'Em breve'),
      VacinaStatus.atrasada => (VetTones.warning, 'Atrasada'),
      VacinaStatus.semPrevisao => (VetColors.brown, 'Sem previsão'),
    };
    return VetCard(
      flat: true,
      color: VetColors.rose.withValues(alpha: .17),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.vaccines_outlined,
                size: 17,
                color: VetColors.brown,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  vaccine.nome,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              StatusChip(label, color, dense: true),
              if (onEdit != null)
                SizedBox(
                  width: 48,
                  height: 48,
                  child: PopupMenuButton<String>(
                    enabled: enabled,
                    tooltip: 'Opções da vacina ${vaccine.nome}',
                    padding: EdgeInsets.zero,
                    iconSize: 18,
                    onSelected: (value) =>
                        value == 'edit' ? onEdit!() : onDelete!(),
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Editar')),
                      PopupMenuItem(value: 'delete', child: Text('Excluir')),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Aplicada: ${fmtData(vaccine.aplicada)}',
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            vaccine.proxima == null
                ? 'Próxima dose: não informada'
                : 'Próxima: ${fmtData(vaccine.proxima!)}',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
