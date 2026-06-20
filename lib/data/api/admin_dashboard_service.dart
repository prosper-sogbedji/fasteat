import 'api_client.dart';
import 'api_config.dart';

class AdminDashboardService {
  AdminDashboardService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<Map<String, dynamic>> getDashboard() async {
    return ApiClient.extractMap(await _client.get(ApiConfig.adminDashboard));
  }

  Future<List<Map<String, dynamic>>> getUsers({String status = 'all'}) async {
    final res = await _client.get(
      ApiConfig.adminUsers,
      queryParameters: {'status': status},
    );
    return ApiClient.extractList(res).map(_mapUser).toList();
  }

  Future<List<Map<String, dynamic>>> getRestaurants({String status = 'all'}) async {
    final res = await _client.get(
      ApiConfig.adminRestaurants,
      queryParameters: {'status': status},
    );
    return ApiClient.extractList(res).map(_mapRestaurant).toList();
  }

  Future<void> updateUserStatus(String userId, String status) async {
    await _client.patch(
      ApiConfig.adminUserStatus(userId),
      body: {'status': status},
    );
  }

  Future<void> updateRestaurantStatus(String restaurantId, String status) async {
    await _client.patch(
      ApiConfig.adminRestaurantStatus(restaurantId),
      body: {'status': status},
    );
  }

  Map<String, dynamic> _mapUser(dynamic raw) {
    final m = raw is Map<String, dynamic> ? raw : Map<String, dynamic>.from(raw as Map);
    return {
      'id': (m['id'] ?? m['_id'] ?? m['userId'] ?? '').toString(),
      'name': (m['name'] ?? m['fullName'] ?? 'Utilisateur').toString(),
      'email': (m['email'] ?? '').toString(),
      'phone': (m['phoneNumber'] ?? m['phone'] ?? '').toString(),
      'role': (m['role'] ?? m['userRole'] ?? 'client').toString(),
      'status': (m['status'] ?? 'active').toString(),
      'createdAt': m['createdAt']?.toString(),
    };
  }

  Map<String, dynamic> _mapRestaurant(dynamic raw) {
    final m = raw is Map<String, dynamic> ? raw : Map<String, dynamic>.from(raw as Map);
    return {
      'id': (m['id'] ?? m['_id'] ?? m['restaurantId'] ?? '').toString(),
      'name': (m['name'] ?? m['restaurantName'] ?? 'Restaurant').toString(),
      'owner': (m['ownerName'] ?? m['managerName'] ?? m['owner']?['name'] ?? '').toString(),
      'email': (m['email'] ?? '').toString(),
      'phone': (m['phoneNumber'] ?? m['phone'] ?? '').toString(),
      'address': (m['address'] ?? m['quartier'] ?? '').toString(),
      'city': (m['city'] ?? m['ville'] ?? 'Cotonou').toString(),
      'status': (m['status'] ?? 'active').toString(),
      'category': (m['cuisineType'] ?? m['category'] ?? '').toString(),
      'rating': ApiClient.toDouble(m['rating'] ?? m['note']),
      'ordersCount': ApiClient.toInt(m['ordersCount'] ?? m['totalOrders']),
      'revenue': ApiClient.toInt(m['revenue'] ?? m['totalRevenue']),
      'createdAt': m['createdAt']?.toString(),
    };
  }
}
