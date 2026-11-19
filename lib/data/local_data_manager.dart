import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'vet_repository.dart';

/// Preferências locais que pertencem ao protótipo e não ao tema visual.
class LocalDataManager {
  LocalDataManager._();

  static const rememberedEmailKey = 'vethome.login.rememberedEmail.v1';
  static Future<bool>? _clearUserDataOperation;

  /// Remove o perfil salvo e o e-mail lembrado sem apagar a preferência de tema.
  /// Retorna false se não for possível confirmar a remoção dos dados do perfil.
  static Future<bool> clearUserData() {
    final operation = _clearUserDataOperation;
    if (operation != null) return operation;

    final completer = Completer<bool>();
    final sharedOperation = completer.future;
    _clearUserDataOperation = sharedOperation;
    unawaited(
      _clearUserDataOnce().then<void>(
        (result) {
          if (identical(_clearUserDataOperation, sharedOperation)) {
            _clearUserDataOperation = null;
          }
          completer.complete(result);
        },
        onError: (Object error, StackTrace stackTrace) {
          if (identical(_clearUserDataOperation, sharedOperation)) {
            _clearUserDataOperation = null;
          }
          completer.completeError(error, stackTrace);
        },
      ),
    );
    return sharedOperation;
  }

  static Future<bool> _clearUserDataOnce() async {
    late final String? rememberedEmail;
    late final SharedPreferences preferences;
    try {
      preferences = await SharedPreferences.getInstance();
      await preferences.reload();
      rememberedEmail = preferences.getString(rememberedEmailKey);
      if (rememberedEmail != null) {
        await preferences.remove(rememberedEmailKey);
        if (preferences.containsKey(rememberedEmailKey)) return false;
      }
    } catch (_) {
      return false;
    }

    if (await VetRepository.clearLocalData()) return true;

    if (rememberedEmail != null) {
      try {
        await preferences.setString(rememberedEmailKey, rememberedEmail);
      } catch (_) {
        // O perfil salvo permanece intacto; falha de recuperação não é
        // disfarçada como limpeza concluída.
      }
    }
    return false;
  }
}
