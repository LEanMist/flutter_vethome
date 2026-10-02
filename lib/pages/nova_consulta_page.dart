import 'package:flutter/material.dart';

import '../data/vet_repository.dart';
import '../models/pet_model.dart';
import '../models/vet_models.dart';
import '../theme/vet_colors.dart';
import '../widgets/pet_avatar.dart';
import '../widgets/pets/pets_theme.dart';
import '../widgets/vet_card.dart';
import '../widgets/vet_page_scaffold.dart';

class NovaConsultaPage extends StatefulWidget {
  const NovaConsultaPage({
    required this.pet,
    required this.service,
    required this.plan,
    super.key,
  });

  final PetModel pet;
  final String service;
  final String plan;

  @override
  State<NovaConsultaPage> createState() => _NovaConsultaPageState();
}

class _NovaConsultaPageState extends State<NovaConsultaPage> {
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 12, minute: 0);
  final _description = TextEditingController();

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _chooseDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _date.isBefore(now) ? now : _date,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
    );
    if (date != null && mounted) setState(() => _date = date);
  }

  Future<void> _chooseTime() async {
    const options = [12, 13, 14, 15, 16];
    final time = await showDialog<TimeOfDay>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: VetColors.pink,
        title: const Text('Escolha o horário'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final hour in options)
              ChoiceChip(
                label: Text('${hour.toString().padLeft(2, '0')}:00'),
                selected: _time.hour == hour && _time.minute == 0,
                selectedColor: VetColors.roseDark,
                labelStyle: TextStyle(
                  color: _time.hour == hour && _time.minute == 0
                      ? Colors.white
                      : VetColors.brown,
                ),
                onSelected: (_) =>
                    Navigator.pop(context, TimeOfDay(hour: hour, minute: 0)),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
    if (time != null && mounted) setState(() => _time = time);
  }

  void _schedule() {
    final dateTime = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );
    if (dateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escolha uma data e horário futuros.')),
      );
      return;
    }
    VetRepository.addAgendamento(
      widget.pet.name,
      Agendamento(
        data: dateTime,
        tipo: widget.service,
        veterinario: 'Dra. Ana Silva',
        local: 'VetHome · ${widget.plan}',
        status: StatusAgendamento.pendente,
        descricao: _description.text.trim(),
      ),
    );
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/agenda',
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = PetsTheme.scaleOf(context);
    return VetPageScaffold(
      title: 'Novo agendamento',
      pet: widget.pet,
      selectedIndex: 3,
      children: [
        VetCard(
          child: Row(
            children: [
              PetAvatar(image: widget.pet.imagePath, size: 56),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.pet.name,
                      style: TextStyle(
                        color: VetColors.brown,
                        fontWeight: FontWeight.bold,
                        fontSize: 18 * scale,
                      ),
                    ),
                    Text(
                      '${widget.service} · ${widget.plan}',
                      style: TextStyle(
                        color: VetColors.brown,
                        fontSize: 13 * scale,
                      ),
                    ),
                    SizedBox(height: 4 * scale),
                    Text(
                      'Exame veterinário para acompanhamento da saúde.',
                      style: TextStyle(
                        color: VetColors.brown.withValues(alpha: 0.75),
                        fontSize: 12 * scale,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        VetCard(
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_month),
                title: const Text('Data'),
                subtitle: Text(
                  '${_date.day.toString().padLeft(2, '0')}/'
                  '${_date.month.toString().padLeft(2, '0')}/${_date.year}',
                ),
                trailing: const Icon(Icons.edit_calendar),
                onTap: _chooseDate,
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule),
                title: const Text('Horário inicial'),
                subtitle: Text(_time.format(context)),
                trailing: const Icon(Icons.edit),
                onTap: _chooseTime,
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule_outlined),
                title: const Text('Horário final'),
                subtitle: Text(
                  TimeOfDay(
                    hour: (_time.hour + 1) % 24,
                    minute: _time.minute,
                  ).format(context),
                ),
              ),
            ],
          ),
        ),
        VetCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _description,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Adicionar uma descrição',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10 * scale),
              Text(
                'Agendamento para ${VetRepository.clientName}',
                style: TextStyle(color: VetColors.brown, fontSize: 13 * scale),
              ),
            ],
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _schedule,
            style: ElevatedButton.styleFrom(
              backgroundColor: VetColors.brown,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14 * scale),
            ),
            child: const Text('Confirmar agendamento'),
          ),
        ),
      ],
    );
  }
}
