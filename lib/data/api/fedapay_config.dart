import 'package:feda_flutter/feda_flutter.dart';

/// Clé publique FedaPay.
const String fedapayPublicKey = 'pk_live_xzioUgEMqsrIEMi0eE0YV2-d';

/// Environnement (sandbox pour les tests, live pour la production)
const ApiEnvironment fedapayEnvironment = ApiEnvironment.sandbox;

void initFedaPay() {
  FedaFlutter.applyConfig(
    apiKey: fedapayPublicKey,
    environment: fedapayEnvironment,
  );
}
