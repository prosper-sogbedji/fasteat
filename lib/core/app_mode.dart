/// Contrôle global du mode de fonctionnement de FastEat.
///
/// **DEMO** : données fictives locales (images, restaurants, plats).
///   → Activé par défaut en développement.
///   → Peut être forcé avec `--dart-define=FASTEAT_DEMO=true`.
///
/// **API** : données réelles depuis le backend.
///   → Activé avec `--dart-define=FASTEAT_DEMO=false`
///     ou via le menu développeur (debug uniquement).
///
/// Ce flag n'est PAS accessible aux utilisateurs finaux.
class AppMode {
  AppMode._();

  /// Source de vérité : démarre en DEMO par défaut.
  /// En production, passer `--dart-define=FASTEAT_DEMO=false` au build.
  static bool _isDemoMode = const bool.fromEnvironment(
    'FASTEAT_DEMO',
    defaultValue: true,
  );

  static bool get isDemoMode => _isDemoMode;
  static bool get isApiMode => !_isDemoMode;

  /// Bascule entre DEMO et API.
  /// Réservé au menu développeur (debug builds uniquement).
  static void toggle() {
    _isDemoMode = !_isDemoMode;
  }

  /// Force le mode explicitement.
  /// Réservé au menu développeur.
  static void setDemoMode({required bool enabled}) {
    _isDemoMode = enabled;
  }
}
