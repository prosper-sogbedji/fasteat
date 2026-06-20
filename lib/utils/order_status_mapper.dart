/// Conversion entre statuts API (anglais) et libellés UI (français).
class OrderStatusMapper {
  static const _uiToApi = {
    'NOUVEAU': 'accepted',
    'ACCEPTÉ': 'accepted',
    'ACCEPTE': 'accepted',
    'PREPARATION': 'preparing',
    'PRÉPARATION': 'preparing',
    'PRÊTE': 'ready',
    'PRETE': 'ready',
    'EN LIVRAISON': 'out_for_delivery',
    'LIVRÉE': 'delivered',
    'LIVREE': 'delivered',
    'ANNULÉE': 'cancelled',
    'ANNULEE': 'cancelled',
    'REJETÉE': 'rejected',
    'REJETEE': 'rejected',
  };

  static String toUi(String? apiStatus) {
    return switch (apiStatus?.toLowerCase()) {
      'pending' || 'received' || 'new' => 'NOUVEAU',
      'accepted' => 'NOUVEAU',
      'preparing' || 'preparation' => 'PREPARATION',
      'ready' || 'prete' => 'PRÊTE',
      'out_for_delivery' || 'delivery' => 'EN LIVRAISON',
      'delivered' || 'livree' => 'LIVRÉE',
      'cancelled' || 'cancelled_by_restaurant' || 'cancelled_by_customer' => 'ANNULÉE',
      'rejected' => 'REJETÉE',
      null || '' => 'NOUVEAU',
      _ => apiStatus!.toUpperCase(),
    };
  }

  static String toApi(String uiStatus) {
    final normalized = uiStatus.toUpperCase().replaceAll('É', 'E').replaceAll('Ê', 'E');
    return _uiToApi[uiStatus.toUpperCase()] ??
        _uiToApi[normalized] ??
        uiStatus.toLowerCase();
  }
}
