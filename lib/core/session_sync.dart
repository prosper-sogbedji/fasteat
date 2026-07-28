import '../providers/auth_provider.dart';
import '../providers/commandes_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/notifications_provider.dart';
import '../providers/panier_provider.dart';

/// Synchronise les données client après connexion ou validation OTP.
Future<void> syncClientSession({
  required AuthProvider auth,
  required PanierProvider panier,
  required CommandesProvider commandes,
  FavoritesProvider? favorites,
  NotificationsProvider? notifications,
}) async {
  if (!auth.isConnected) return;
  await Future.wait([
    panier.syncFromApi(),
    commandes.refreshFromApi(),
    if (favorites != null) favorites.syncFromApi(),
    if (notifications != null) notifications.refresh(),
  ]);
}

void clearClientSessionData({
  FavoritesProvider? favorites,
  NotificationsProvider? notifications,
}) {
  favorites?.clearOnLogout();
  notifications?.clearOnLogout();
}
