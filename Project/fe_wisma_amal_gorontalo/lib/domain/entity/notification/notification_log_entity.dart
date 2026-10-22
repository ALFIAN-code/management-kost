class NotificationSummaryEntity {
  final int total;
  final int sent;
  final int failed;
  final int today;
  final Map<String, int> byType;

  const NotificationSummaryEntity({
    required this.total,
    required this.sent,
    required this.failed,
    required this.today,
    required this.byType,
  });

  factory NotificationSummaryEntity.fromJson(Map<String, dynamic> json) {
    final data = json["data"] is Map<String, dynamic>
        ? json["data"] as Map<String, dynamic>
        : json;

    final rawByType = data["by_type"];
    final byType = <String, int>{};
    if (rawByType is Map) {
      rawByType.forEach((k, v) {
        byType[k.toString()] = (v is int) ? v : int.tryParse(v.toString()) ?? 0;
      });
    }

    return NotificationSummaryEntity(
      total: _parseInt(data["total"]),
      sent: _parseInt(data["sent"]),
      failed: _parseInt(data["failed"]),
      today: _parseInt(data["today"]),
      byType: byType,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? "") ?? 0;
  }
}

class NotificationRecipientEntity {
  final int id;
  final String name;
  final String? phone;

  const NotificationRecipientEntity({
    required this.id,
    required this.name,
    this.phone,
  });

  factory NotificationRecipientEntity.fromJson(Map<String, dynamic> json) {
    return NotificationRecipientEntity(
      id: (json["id"] is int) ? json["id"] as int : int.tryParse(json["id"].toString()) ?? 0,
      name: json["name"]?.toString() ?? "-",
      phone: json["phone_number"]?.toString(),
    );
  }
}

class NotificationLogItem {
  final int id;
  final String message;
  final String createdAt;
  final String status;
  final bool isRead;
  final String? channel;
  final String? recipient;
  final String? errorResponse;

  const NotificationLogItem({
    required this.id,
    required this.message,
    required this.createdAt,
    required this.status,
    required this.isRead,
    this.channel,
    this.recipient,
    this.errorResponse,
  });

  String get typeLabel => _resolveTypeLabel(channel);

  static String _resolveTypeLabel(String? type) {
    switch (type) {
      case 'payment_receipt':
        return 'Payment';
      case 'payment_reminder':
        return 'Invoice';
      case 'manual_broadcast':
        return 'Broadcast';
      case 'system_alert':
        return 'System';
      case 'guest_registered':
        return 'Guest Check-In';
      case 'guest_stay_ended':
        return 'Guest Check-Out';
      case 'pembayaran_diterima':
        return 'Payment Received';
      case 'pembayaran_dibatalkan':
        return 'Payment Cancelled';
      case 'jadwal_dibuat':
        return 'Schedule Created';
      case 'jadwal_sewa_aktif':
        return 'Lease Active';
      case 'jadwal_sewa_selesai':
        return 'Lease Ended';
      case 'jadwal_batal':
        return 'Schedule Cancelled';
      case 'laporan_kerusakan':
        return 'Damage';
      default:
        return type ?? '-';
    }
  }

  factory NotificationLogItem.fromJson(Map<String, dynamic> json) {
    final message = _resolveMessage(json);
    return NotificationLogItem(
      id: _parseInt(json['id']),
      message: message,
      createdAt: json['created_at']?.toString() ??
          json['createdAt']?.toString() ??
          json['sent_at']?.toString() ??
          json['sentAt']?.toString() ??
          '-',
      status: _resolveStatus(json['status']?.toString()),
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      // 'type' from the backend (enum value: guest_registered, etc.)
      channel: json['type']?.toString() ??
          json['channel']?.toString() ??
          json['provider']?.toString(),
      recipient: json['target_phone']?.toString() ??
          json['recipient']?.toString() ??
          json['to']?.toString() ??
          json['target']?.toString(),
      errorResponse: json['error_response']?.toString(),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _resolveStatus(String? raw) {
    switch (raw) {
      case 'sent':
        return 'Sent';
      case 'failed':
        return 'Failed';
      case 'pending':
        return 'Pending';
      default:
        return raw ?? '-';
    }
  }

  static String _resolveMessage(Map<String, dynamic> json) {
    // 'message_body' is the main field of the backend NotificationLog model
    final raw = json['message_body'] ??
        json['message'] ??
        json['title'] ??
        json['body'] ??
        json['content'] ??
        json['description'];

    if (raw != null && raw.toString().trim().isNotEmpty) {
      return raw.toString();
    }

    return '-';
  }
}

class NotificationLogPagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const NotificationLogPagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory NotificationLogPagination.fromJson(Map<String, dynamic> json) {
    return NotificationLogPagination(
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? 10,
      total: json['total'] as int? ?? 0,
    );
  }
}

class NotificationLogResponse {
  final List<NotificationLogItem> logs;
  final NotificationLogPagination pagination;
  /// Number of unread notifications (from the 'unread_count' field in the root response)
  final int unreadCount;

  const NotificationLogResponse({
    required this.logs,
    required this.pagination,
    required this.unreadCount,
  });

  factory NotificationLogResponse.fromJson(Map<String, dynamic> json) {
    // 'unread_count' is in the root response: { success, data: {...paginator...}, unread_count: N }
    final unreadCount = json['unread_count'] as int? ?? 0;

    final data = json['data'];
    List<dynamic> items = <dynamic>[];
    Map<String, dynamic> metaMap = <String, dynamic>{};

    if (data is Map<String, dynamic>) {
      // Laravel paginator: data.data = array of items
      if (data['data'] is List<dynamic>) {
        items = data['data'] as List<dynamic>;
      } else if (data['logs'] is List<dynamic>) {
        items = data['logs'] as List<dynamic>;
      } else if (data['items'] is List<dynamic>) {
        items = data['items'] as List<dynamic>;
      } else if (data['records'] is List<dynamic>) {
        items = data['records'] as List<dynamic>;
      }

      // Pagination metadata is directly in data (Laravel paginator)
      if (data['meta'] is Map<String, dynamic>) {
        metaMap = Map<String, dynamic>.from(data['meta'] as Map);
      } else if (data['pagination'] is Map<String, dynamic>) {
        metaMap = Map<String, dynamic>.from(data['pagination'] as Map);
      } else if (data.containsKey('current_page')) {
        metaMap = data;
      }
    } else if (data is List<dynamic>) {
      items = data;
    }

    return NotificationLogResponse(
      logs: items
          .map((e) => NotificationLogItem.fromJson(
              e is Map<String, dynamic> ? e : <String, dynamic>{}))
          .toList(),
      pagination: NotificationLogPagination.fromJson(metaMap),
      unreadCount: unreadCount,
    );
  }
}
