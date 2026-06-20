class ApiConfig {
  static const String baseUrl = 'https://fast-eat-npb7.onrender.com/api/v1';
  static const Duration requestTimeout = Duration(seconds: 15);

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String verifyOtp = '/auth/otp/verify';
  static const String resendOtp = '/auth/otp/resend';
  static const String me = '/auth/me';
  static const String forgotPassword = '/auth/password/forgot';
  static const String resetPassword = '/auth/password/reset';

  // Admin
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static String adminUserStatus(String userId) => '/admin/users/$userId/status';
  static const String adminRestaurants = '/admin/restaurants';
  static String adminRestaurantStatus(String restaurantId) =>
      '/admin/restaurants/$restaurantId/status';

  // Restaurant Dashboard
  static const String dashboardProfile = '/restaurant-dashboard/profile';
  static const String dashboardMenuItems = '/restaurant-dashboard/menu-items';
  static const String dashboardMenuCategories = '/restaurant-dashboard/menu-categories';
  static const String dashboardOrders = '/restaurant-dashboard/orders';
  static String dashboardOrder(String orderId) => '/restaurant-dashboard/orders/$orderId';
  static String dashboardOrderStatus(String orderId) =>
      '/restaurant-dashboard/orders/$orderId/status';
  static const String dashboardHours = '/restaurant-dashboard/hours';
  static const String dashboardPromotions = '/restaurant-dashboard/promotions';
  static const String dashboardAnalytics = '/restaurant-dashboard/analytics/summary';
  static const String dashboardChatConversations = '/restaurant-dashboard/chat/conversations';
  static String dashboardMenuItem(String itemId) => '/restaurant-dashboard/menu-items/$itemId';
  static String dashboardMenuItemAvailability(String itemId) =>
      '/restaurant-dashboard/menu-items/$itemId/availability';
  static String dashboardMenuCategory(String categoryId) =>
      '/restaurant-dashboard/menu-categories/$categoryId';
}
