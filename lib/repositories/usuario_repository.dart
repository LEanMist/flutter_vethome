import '../models/usuario.dart';

abstract class UsuarioRepository {
  List<Usuario> findAll();
  Usuario? findById(String id);
  Usuario? findByEmail(String email);
  Usuario? findByNome(String nome);
  Usuario? findByCpf(String cpf);
  Usuario? autenticar(String identificador, String senha);
  void save(Usuario usuario, {String? senha});
}

class InMemoryUsuarioRepository implements UsuarioRepository {
  InMemoryUsuarioRepository({bool incluirUsuarioTeste = false}) {
    if (incluirUsuarioTeste) _criarUsuarioTeste();
  }

  static const usuarioTesteNome = 'Usuario Teste';
  static const usuarioTesteEmail = 'teste@vethome.com';
  static const usuarioTesteSenha = 'Teste123';

  static final InMemoryUsuarioRepository instance = InMemoryUsuarioRepository(
    incluirUsuarioTeste: true,
  );

  final Map<String, Usuario> _usuarios = <String, Usuario>{};
  final Map<String, String> _senhasPorUsuarioId = <String, String>{};

  void _criarUsuarioTeste() {
    save(
      Usuario(
        nome: usuarioTesteNome,
        dataNascimento: DateTime(1990, 1, 1),
        genero: GeneroUsuario.prefiroNaoInformar,
        cpf: '529.982.247-25',
        telefone: '11987654321',
        cep: '01001000',
        endereco: 'Rua de Teste',
        numero: '1',
        complemento: '',
        cidade: 'São Paulo',
        email: usuarioTesteEmail,
      ),
      senha: usuarioTesteSenha,
    );
  }

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
  Usuario? findByNome(String nome) {
    final normalizedName = _normalizeNome(nome);
    for (final usuario in _usuarios.values) {
      if (_normalizeNome(usuario.nome) == normalizedName) return usuario;
    }
    return null;
  }

  @override
  Usuario? autenticar(String identificador, String senha) {
    final usuario = findByEmail(identificador) ?? findByNome(identificador);
    final id = usuario?.id;
    if (id == null || _senhasPorUsuarioId[id] != senha) return null;
    return usuario;
  }

  static String _normalizeNome(String nome) => nome.trim().toLowerCase();

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
  void save(Usuario usuario, {String? senha}) {
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
    if (senha != null) _senhasPorUsuarioId[id] = senha;
  }
}
