import '../models/usuario.dart';

abstract class UsuarioRepository {
  List<Usuario> findAll();
  Usuario? findById(String id);
  Usuario? findByEmail(String email);
  Usuario? findByCpf(String cpf);
  void save(Usuario usuario);
}

class InMemoryUsuarioRepository implements UsuarioRepository {
  InMemoryUsuarioRepository();

  static final InMemoryUsuarioRepository instance = InMemoryUsuarioRepository();

  final Map<String, Usuario> _usuarios = <String, Usuario>{};

  @override
  List<Usuario> findAll() => List<Usuario>.unmodifiable(_usuarios.values);

  @override
  Usuario? findById(String id) => _usuarios[id];

  @override
  Usuario? findByEmail(String email) {
    final normalizedEmail = Usuario.normalizeEmail(email);
    for (final usuario in _usuarios.values) {
      if (Usuario.normalizeEmail(usuario.email) == normalizedEmail) {
        return usuario;
      }
    }
    return null;
  }

  @override
  Usuario? findByCpf(String cpf) {
    final normalizedCpf = Usuario.normalizeCpf(cpf);
    for (final usuario in _usuarios.values) {
      if (Usuario.normalizeCpf(usuario.cpf) == normalizedCpf) {
        return usuario;
      }
    }
    return null;
  }

  @override
  void save(Usuario usuario) {
    if (usuario.errors.isNotEmpty) {
      throw ArgumentError(
        'Usuário inválido: ${usuario.errors.values.join('; ')}',
      );
    }

    final duplicateEmail = findByEmail(usuario.email);
    if (duplicateEmail != null && duplicateEmail.id != usuario.id) {
      throw ArgumentError('Este e-mail já está cadastrado.');
    }

    final duplicateCpf = findByCpf(usuario.cpf);
    if (duplicateCpf != null && duplicateCpf.id != usuario.id) {
      throw ArgumentError('Este CPF já está cadastrado.');
    }

    final id =
        usuario.id ??
        'usuario-${DateTime.now().microsecondsSinceEpoch}-${_usuarios.length}';
    _usuarios[id] = usuario.copyWith(id: id);
  }
}
