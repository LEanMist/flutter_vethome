import 'package:flutter/material.dart';

import '../data/local_storage.dart';
import '../theme/vet_colors.dart';

class CriticalStorageErrorPage extends StatefulWidget {
  const CriticalStorageErrorPage({
    required this.status,
    this.onRetry,
    this.onClear,
    super.key,
  });

  final LocalLoadStatus status;

  /// Nova leitura segura; só é oferecida quando o armazenamento está
  /// indisponível.
  final Future<void> Function()? onRetry;

  /// Exclusão explícita disponível apenas para snapshot inválido.
  final Future<bool> Function()? onClear;

  @override
  State<CriticalStorageErrorPage> createState() =>
      _CriticalStorageErrorPageState();
}

class _CriticalStorageErrorPageState extends State<CriticalStorageErrorPage> {
  bool _retrying = false;
  bool _clearing = false;

  Future<void> _retry() async {
    setState(() => _retrying = true);
    try {
      await widget.onRetry!();
    } catch (_) {
      debugPrint('VetHome: falha ao tentar acessar o armazenamento novamente.');
    } finally {
      if (mounted) setState(() => _retrying = false);
    }
  }

  Future<void> _clear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apagar os dados salvos?'),
        content: const Text(
          'Isso remove o perfil, o e-mail lembrado, pets cadastrados, fotos, endereços, consultas e vacinas deste dispositivo. Os dados demonstrativos iniciais continuarão disponíveis; a preferência de tema será mantida. Essa ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Apagar dados'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _clearing = true);
    try {
      final cleared = await widget.onClear!();
      if (!mounted || cleared) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível confirmar a remoção dos dados. Tente novamente.',
            ),
          ),
        );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível confirmar a remoção dos dados. Tente novamente.',
            ),
          ),
        );
    } finally {
      if (mounted) setState(() => _clearing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unavailable = widget.status == LocalLoadStatus.unavailable;
    return Scaffold(
      backgroundColor: VetColors.pink,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    size: 48,
                    color: VetColors.brown,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Seus dados locais estão protegidos',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: VetColors.brown,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    unavailable
                        ? 'O armazenamento não está disponível. Feche e abra o aplicativo novamente. Seus dados não foram alterados.'
                        : widget.onClear == null
                        ? 'Não foi possível ler os dados salvos. Eles não foram alterados. Feche o aplicativo e procure suporte antes de continuar.'
                        : 'Não foi possível ler os dados salvos. Eles continuam preservados. Você pode tentar recuperar o acesso ou apagar os dados salvos e iniciar a demonstração novamente.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: VetColors.brown,
                      height: 1.45,
                    ),
                  ),
                  if (unavailable && widget.onRetry != null) ...[
                    const SizedBox(height: 20),
                    FilledButton(
                      key: const ValueKey('critical-storage-retry'),
                      onPressed: _retrying ? null : _retry,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                  if (!unavailable && widget.onClear != null) ...[
                    const SizedBox(height: 12),
                    OutlinedButton(
                      key: const ValueKey('critical-storage-clear'),
                      onPressed: _clearing ? null : _clear,
                      child: Text(
                        _clearing ? 'Apagando…' : 'Apagar dados salvos',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
