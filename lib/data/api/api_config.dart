class ApiConfig {
  static const String baseUrl = 'https://fast-eat-npb7.onrender.com/api/v1';

  // Auth Endpoints
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String verifyOtp = '/auth/otp/verify';
  static const String resendOtp = '/auth/otp/resend';
  static const String me = '/auth/me';

  // Public restaurant endpoints
  static const String restaurants = '/restaurants';
  static String restaurant(String id) => '/restaurants/$id';
  static String restaurantMenu(String id) => '/restaurants/$id/menu';
  static String restaurantMenuItem(String restaurantId, String itemId) =>
      '/restaurants/$restaurantId/menu/items/$itemId';

  // Cart endpoints
  static const String cart = '/cart';
  static const String cartItems = '/cart/items';
  static String cartItem(String itemId) => '/cart/items/$itemId';
  static const String cartFulfillment = '/cart/fulfillment';
  static const String cartInstructions = '/cart/instructions';
  static const String cartCheckout = '/cart/checkout';

  // Orders endpoints
  static const String orders = '/orders';
  static String order(String orderId) => '/orders/$orderId';
  static String orderTracking(String orderId) => '/orders/$orderId/tracking';
  static String orderCancel(String orderId) => '/orders/$orderId/cancel';
  static String orderReorder(String orderId) => '/orders/$orderId/reorder';

  // Payments endpoints
  static const String paymentMethods = '/payments/methods';
  static const String paymentInitiate = '/payments/initiate';
  static String payment(String paymentId) => '/payments/$paymentId';
  static String paymentConfirm(String paymentId) => '/payments/$paymentId/confirm';
  static String paymentRefundRequest(String paymentId) => '/payments/$paymentId/refund-request';

  // Favorites endpoints
  static const String favorites = '/favorites';
  static String favoriteRestaurant(String restaurantId) => '/favorites/restaurants/$restaurantId';

  // Notifications endpoints
  static const String notifications = '/notifications';
  static String notificationRead(String notificationId) => '/notifications/$notificationId/read';
  static const String notificationsReadAll = '/notifications/read-all';

  // Reservations endpoints
  static const String reservations = '/reservations';
  static String reservation(String id) => '/reservations/$id';
  static String cancelReservation(String id) => '/reservations/$id/cancel';
}
