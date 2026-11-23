import '../data/vet_repository.dart';

enum UserRole { cliente, veterinaria }

class AuthenticatedUser {
  const AuthenticatedUser({required this.id, required this.role});

  final String id;
  final UserRole role;
}

abstract interface class Authentication {
  Future<AuthenticatedUser?> signIn({
    required String email,
    required String password,
  });
}

/// Contas públicas para apresentação com dados fictícios. Não valida uma
/// identidade real, e a autorização simulada vale só durante esta sessão.
class DemoAuthentication implements Authentication {
  const DemoAuthentication();

  static const enabled = bool.fromEnvironment('VETHOME_DEMO_MODE');
  static const clientEmail = 'cliente@vethome.example';
  static const veterinarianEmail = 'gabriela@vethome.example';
  static const demoPassword = 'VetHomeDemo';

  @override
  Future<AuthenticatedUser?> signIn({
    required String email,
    required String password,
  }) async {
    if (password != demoPassword) return null;
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail == veterinarianEmail) {
      return const AuthenticatedUser(
        id: 'demo-veterinaria',
        role: UserRole.veterinaria,
      );
    }
    if (normalizedEmail == clientEmail ||
        (normalizedEmail.isNotEmpty &&
            normalizedEmail ==
                VetRepository.clientEmail.trim().toLowerCase())) {
      return const AuthenticatedUser(
        id: 'demo-cliente',
        role: UserRole.cliente,
      );
    }
    return null;
  }
}
