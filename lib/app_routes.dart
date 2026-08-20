abstract final class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const connexion = '/connexion';
  static const inscription = '/inscription';
  static const otp = '/otp';
  static const home = '/home';
  static const recherche = '/recherche';
  static const restaurant = '/restaurant';
  static const plat = '/plat';
  static const panier = '/panier';
  static const panierProgrammee = '/panier/programmee';
  static const panierQr = '/panier/qr';
  static const qrScanner = '/qr-scanner';
  static const paiementChoix = '/paiement/choix';
  static const paiementProcessing = '/paiement/processing';
  static const commandeConfirmee = '/commande/confirmee';
  static const suivi = '/suivi';
  static const historique = '/historique'; // keeping for compatibility or internal use if needed
  static const activite = '/activite';
  static const avis = '/avis';
  static const chat = '/chat';
  static const profil = '/profil';
  static const parrainage = '/parrainage';
  static const mesInfos = '/mes-infos';
  static const adresses = '/adresses';
  static const parametres = '/parametres';
  static const aide = '/aide';
  static const mesRestaurants = '/mes-restaurants';
  // Kept for backward compat (redirects to mesRestaurants)
  static const favoris = '/mes-restaurants';
  static const notifications = '/notifications';
  // Reservations
  static const reservations = '/reservations';
  static const nouvelleReservation = '/reservations/nouvelle';
}
