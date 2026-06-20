import 'api_client.dart';
import 'api_config.dart';
import '../../utils/order_status_mapper.dart';
import '../../utils/date_formatters.dart';

class RestaurantDashboardService {
  RestaurantDashboardService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  static const _orderStatuses = [
    'all',
    'pending',
    'accepted',
    'preparing',
    'ready',
    'out_for_delivery',
    'delivered',
    'cancelled',
  ];

  // ─── Menu ───────────────────────────────────────────────────────────────────

  Future<List<dynamic>> getMenuCategories() async {
    final res = await _client.get(ApiConfig.dashboardMenuCategories);
    return ApiClient.extractList(res);
  }

  Future<dynamic> createMenuCategory(String name) async {
    return _client.post(ApiConfig.dashboardMenuCategories, body: {'name': name});
  }

  Future<List<dynamic>> getMenuItems() async {
    final res = await _client.get(ApiConfig.dashboardMenuItems);
    return ApiClient.extractList(res);
  }

  Future<dynamic> createMenuItem(Map<String, dynamic> itemData) async {
    return _client.post(ApiConfig.dashboardMenuItems, body: itemData);
  }

  Future<dynamic> updateMenuItem(String itemId, Map<String, dynamic> itemData) async {
    return _client.put(ApiConfig.dashboardMenuItem(itemId), body: itemData);
  }

  Future<dynamic> updateMenuItemAvailability(String itemId, bool isAvailable) async {
    return _client.patch(
      ApiConfig.dashboardMenuItemAvailability(itemId),
      body: {'isAvailable': isAvailable},
    );
  }

  Future<dynamic> deleteMenuItem(String itemId) async {
    return _client.delete(ApiConfig.dashboardMenuItem(itemId));
  }

  // ─── Commandes ──────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getOrders() async {
    final seen = <String>{};
    final merged = <Map<String, dynamic>>[];

    for (final status in _orderStatuses) {
      try {
        final res = await _client.get(
          ApiConfig.dashboardOrders,
          queryParameters: {'status': status},
        );
        for (final raw in ApiClient.extractList(res)) {
          final order = _mapOrder(raw);
          final id = order['id']?.toString() ?? '';
          if (id.isNotEmpty && seen.add(id)) {
            merged.add(order);
          }
        }
      } catch (_) {
        // Certaines valeurs de status peuvent ne pas être supportées — on continue.
      }
    }

    merged.sort((a, b) {
      final da = a['_sortDate'] as DateTime? ?? DateTime.fromMillisecondsSinceEpoch(0);
      final db = b['_sortDate'] as DateTime? ?? DateTime.fromMillisecondsSinceEpoch(0);
      return db.compareTo(da);
    });

    return merged;
  }

  Future<Map<String, dynamic>?> getOrderDetail(String orderId) async {
    final res = await _client.get(ApiConfig.dashboardOrder(orderId));
    final map = ApiClient.extractMap(res);
    if (map.isEmpty) return null;
    return _mapOrder(map);
  }

  Future<void> updateOrderStatus(String orderId, String uiStatus) async {
    await _client.patch(
      ApiConfig.dashboardOrderStatus(orderId),
      body: {'status': OrderStatusMapper.toApi(uiStatus)},
    );
  }

  Map<String, dynamic> _mapOrder(dynamic raw) {
    final map = raw is Map<String, dynamic> ? raw : Map<String, dynamic>.from(raw as Map);
    final items = (map['items'] ?? map['orderItems'] ?? map['lignes']) as List? ?? [];
    final createdAt = (map['createdAt'] ?? map['date'] ?? map['orderedAt'])?.toString();

    DateTime? sortDate;
    if (createdAt != null) {
      try {
        sortDate = DateTime.parse(createdAt);
      } catch (_) {}
    }

    return {
      'id': (map['id'] ?? map['_id'] ?? map['orderId'] ?? '').toString(),
      'client': (map['clientName'] ??
              map['customerName'] ??
              map['customer']?['name'] ??
              map['client']?['name'] ??
              'Client FastEat')
          .toString(),
      'items': items.map((it) {
        final item = it is Map<String, dynamic> ? it : Map<String, dynamic>.from(it as Map);
        final menuItem = item['menuItem'];
        final menuMap = menuItem is Map ? menuItem : {};
        return {
          'name': (item['name'] ?? item['nomPlat'] ?? menuMap['name'] ?? 'Article').toString(),
          'qty': ApiClient.toInt(item['quantity'] ?? item['quantite'], fallback: 1),
          'price': ApiClient.toInt(
            item['price'] ?? item['unitPrice'] ?? item['prixUnitaire'] ?? menuMap['price'],
          ),
        };
      }).toList(),
      'total': ApiClient.toInt(
        map['totalPrice'] ?? map['total'] ?? map['amount'] ?? map['grandTotal'],
      ),
      'time': formatRelativeTime(createdAt),
      'status': OrderStatusMapper.toUi(map['status']?.toString()),
      'isPriority': map['isPriority'] == true || map['priority'] == true,
      '_sortDate': sortDate,
      '_rawStatus': map['status']?.toString(),
    };
  }

  // ─── Horaires ───────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getHours() async {
    final res = await _client.get(ApiConfig.dashboardHours);
    return ApiClient.extractList(res).map((e) {
      final m = e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map);
      return {
        'dayOfWeek': ApiClient.toInt(m['dayOfWeek']),
        'opensAt': m['opensAt']?.toString() ?? '09:00',
        'closesAt': m['closesAt']?.toString() ?? '22:00',
        'isClosed': m['isClosed'] == true,
      };
    }).toList();
  }

  Future<void> updateHours(Map<String, dynamic> hoursData) async {
    await _client.put(ApiConfig.dashboardHours, body: hoursData);
  }

  // ─── Promotions ─────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getPromotions() async {
    final res = await _client.get(ApiConfig.dashboardPromotions);
    return ApiClient.extractList(res).map(_mapPromotion).toList();
  }

  Future<Map<String, dynamic>> createPromotion(Map<String, dynamic> data) async {
    final res = await _client.post(ApiConfig.dashboardPromotions, body: data);
    return _mapPromotion(ApiClient.extractMap(res).isNotEmpty ? ApiClient.extractMap(res) : data);
  }

  Map<String, dynamic> _mapPromotion(dynamic raw) {
    final m = raw is Map<String, dynamic> ? raw : Map<String, dynamic>.from(raw as Map);
    final discountType = m['discountType']?.toString() ?? 'percentage';
    final value = ApiClient.toDouble(m['discountValue']);
    final description = m['description']?.toString() ??
        (discountType == 'percentage' ? '-${value.toInt()}%' : '-${value.toInt()} FCFA');

    final now = DateTime.now();
    DateTime? startsAt;
    DateTime? endsAt;
    try {
      startsAt = DateTime.parse(m['startsAt']?.toString() ?? '');
      endsAt = DateTime.parse(m['endsAt']?.toString() ?? '');
    } catch (_) {}

    String status = 'ACTIF';
    if (m['isActive'] == false || m['status']?.toString().toLowerCase() == 'paused') {
      status = 'EN PAUSE';
    } else if (endsAt != null && endsAt.isBefore(now)) {
      status = 'EXPIRÉ';
    } else if (startsAt != null && startsAt.isAfter(now)) {
      status = 'PLANIFIÉ';
    }

    return {
      'id': (m['id'] ?? m['_id'] ?? '').toString(),
      'title': m['title']?.toString() ?? 'Promotion',
      'description': description,
      'status': status,
      'discountType': discountType,
      'discountValue': value,
      'startsAt': m['startsAt']?.toString(),
      'endsAt': m['endsAt']?.toString(),
      'code': m['code']?.toString(),
      'uses': ApiClient.toInt(m['uses'] ?? m['usageCount'], fallback: 0),
      'revenue': ApiClient.toInt(m['revenue'] ?? m['promoRevenue'], fallback: 0),
    };
  }

  // ─── Analytics ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getAnalyticsSummary() async {
    final res = await _client.get(ApiConfig.dashboardAnalytics);
    return ApiClient.extractMap(res);
  }

  // ─── Chat ───────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getConversations() async {
    final res = await _client.get(ApiConfig.dashboardChatConversations);
    return ApiClient.extractList(res).map((e) {
      final m = e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map);
      return {
        'id': (m['id'] ?? m['conversationId'] ?? '').toString(),
        'clientName': (m['clientName'] ?? m['customerName'] ?? m['participant']?['name'] ?? 'Client')
            .toString(),
        'lastMessage': (m['lastMessage'] ?? m['preview'] ?? m['lastMessageText'] ?? '').toString(),
        'updatedAt': (m['updatedAt'] ?? m['lastMessageAt'])?.toString(),
        'orderId': (m['orderId'] ?? m['order']?['id'])?.toString(),
        'avatarUrl': m['avatarUrl']?.toString(),
        'unreadCount': ApiClient.toInt(m['unreadCount'], fallback: 0),
      };
    }).toList();
  }

  // ─── Profil ─────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getProfile() async {
    return ApiClient.extractMap(await _client.get(ApiConfig.dashboardProfile));
  }
}
