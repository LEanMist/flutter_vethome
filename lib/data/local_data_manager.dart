import 'package:shared_preferences/shared_preferences.dart';

import 'vet_repository.dart';

/// Preferências locais que pertencem ao protótipo e não ao tema visual.
class LocalDataManager {
  LocalDataManager._();

  static const rememberedEmailKey = 'vethome.login.rememberedEmail.v1';

  /// Remove o perfil salvo e o e-mail lembrado sem apagar a preferência de tema.
  /// Retorna false se não for possível confirmar a remoção dos dados do perfil.
  static Future<bool> clearUserData() async {
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
