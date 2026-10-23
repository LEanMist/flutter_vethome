import 'package:flutter/material.dart';

import '../data/local_storage.dart';
import '../theme/vet_colors.dart';

class CriticalStorageErrorPage extends StatefulWidget {
  const CriticalStorageErrorPage({
    required this.status,
    this.onRetry,
    super.key,
  });

  final LocalLoadStatus status;

  /// Nova leitura segura; só é oferecida quando o armazenamento está
  /// indisponível. Snapshot inválido nunca tem ação de recuperação aqui.
  final Future<void> Function()? onRetry;

  @override
  State<CriticalStorageErrorPage> createState() =>
      _CriticalStorageErrorPageState();
}

class _CriticalStorageErrorPageState extends State<CriticalStorageErrorPage> {
  bool _retrying = false;

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
                        : 'Não foi possível ler os dados salvos. Eles não foram alterados. Feche o aplicativo e procure suporte antes de continuar.',
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
