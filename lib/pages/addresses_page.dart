import 'package:flutter/material.dart';
import '../data/vet_repository.dart';
import '../models/saved_address.dart';
import '../widgets/address_form.dart';
import '../widgets/vet_page_scaffold.dart';
import '../theme/vet_colors.dart';

class AddressesPage extends StatefulWidget {
  const AddressesPage({super.key});
  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  Future<void> _edit([SavedAddress? address]) async {
    await Navigator.pushNamed(context, '/editar-endereco', arguments: address);
    if (mounted) setState(() {});
  }

  Future<void> _delete(SavedAddress address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir endereço?'),
        content: Text(address.summary),
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
    if (confirmed == true && mounted) {
      setState(() => VetRepository.removeAddress(address.id));
    }
  }

  @override
  Widget build(BuildContext context) => VetPageScaffold(
    title: 'Meus Endereços',
    selectedIndex: 4,
    children: [
      if (VetRepository.addresses.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'Nenhum endereço cadastrado',
            textAlign: TextAlign.center,
          ),
        ),
      for (final a in VetRepository.addresses)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: VetColors.rose.withValues(alpha: .2),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                a.street,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (a.number.isNotEmpty) Text('Número: ${a.number}'),
              if (a.complement.isNotEmpty) Text('Complemento: ${a.complement}'),
              if (a.city.isNotEmpty) Text(a.city),
              if (a.cep.isNotEmpty) Text('CEP: ${a.cep}'),
              Wrap(
                spacing: 12,
                children: [
                  TextButton.icon(
                    onPressed: () => _edit(a),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar'),
                  ),
                  TextButton.icon(
                    onPressed: () => _delete(a),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Excluir'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ElevatedButton.icon(
        onPressed: () => _edit(),
        icon: const Icon(Icons.add),
        label: const Text('Novo endereço'),
      ),
    ],
  );
}

class AddressEditorPage extends StatelessWidget {
  const AddressEditorPage({super.key, this.address});
  final SavedAddress? address;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: VetColors.pink,
    appBar: AppBar(backgroundColor: VetColors.pink),
    body: SafeArea(
      child: AddressForm(
        title: address == null ? 'Novo endereço' : 'Editar endereço',
        initial: address,
        onSaved: (value) {
          VetRepository.saveAddress(value);
          Navigator.pop(context);
        },
      ),
    ),
  );
}
