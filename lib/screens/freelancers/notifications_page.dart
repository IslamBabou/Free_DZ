import 'package:flutter/material.dart';
import 'package:free_dz/models/notifications.dart';
import 'package:free_dz/services/api_helper.dart';

// ==========================================
// FREELANCER NOTIFICATIONS PAGE
// ==========================================

class FreelancerNotificationsPage extends StatefulWidget {
  const FreelancerNotificationsPage({super.key});

  @override
  State<FreelancerNotificationsPage> createState() =>
      _FreelancerNotificationsPageState();
}

class _FreelancerNotificationsPageState
    extends State<FreelancerNotificationsPage> {
  bool _isLoading = true;
  bool _hasError = false;
  bool _isMarkingAllAsRead = false;

  List<NotificationModel> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  // ==========================================
  // LOAD NOTIFICATIONS
  // ==========================================
  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final data = await ApiHelper.get('/notifications');

      final List<dynamic> notificationsJson =
          data is List ? data : (data['data'] as List? ?? []);

      _notifications = notificationsJson
          .map((json) => NotificationModel.fromJson(json))
          .toList();

      _notifications.sort(
        (a, b) => b.createdAt.compareTo(a.createdAt),
      );

      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  // ==========================================
  // MARK ONE AS READ
  // ==========================================
  Future<void> _markNotificationAsRead(NotificationModel notification) async {
    if (notification.isRead) return;

    final index = _notifications.indexWhere((n) => n.id == notification.id);

    if (index == -1) return;

    final original = _notifications[index];

    setState(() {
      _notifications[index] = original.copyWith(isRead: true);
    });

    try {
      await ApiHelper.put(
        '/freelancer/notifications/${notification.id}/read',
        {},
      );
    } catch (e) {
      setState(() {
        _notifications[index] = original;
      });
    }
  }

  // ==========================================
  // MARK ALL AS READ
  // ==========================================
  Future<void> _markAllAsRead() async {
    if (_notifications.every((n) => n.isRead)) return;

    setState(() => _isMarkingAllAsRead = true);

    try {
      await ApiHelper.put('notifications/read-all', {});

      setState(() {
        _notifications =
            _notifications.map((n) => n.copyWith(isRead: true)).toList();
        _isMarkingAllAsRead = false;
      });

      _showSnackBar('All notifications marked as read');
    } catch (e) {
      setState(() => _isMarkingAllAsRead = false);
      _showSnackBar('Failed to mark all as read', isError: true);
    }
  }

  // ==========================================
  // TAP HANDLER
  // ==========================================
  void _onNotificationTap(NotificationModel notification) {
    _markNotificationAsRead(notification);

    final type = NotificationType.fromString(notification.type);

    switch (type) {
      case NotificationType.job:
        debugPrint('Navigate to job details');
        break;
      case NotificationType.message:
        debugPrint('Navigate to messages');
        break;
      case NotificationType.system:
        debugPrint('System notification tapped');
        break;
    }
  }

  // ==========================================
  // UI
  // ==========================================
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasUnread = _notifications.any((n) => !n.isRead);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade50,
      appBar: _buildAppBar(isDark, hasUnread),
      body: _buildBody(isDark),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark, bool hasUnread) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      elevation: 1,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back),
      ),
      title: const Text(
        'Notifications',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      actions: [
        if (!_isLoading && hasUnread)
          _isMarkingAllAsRead
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : TextButton(
                  onPressed: _markAllAsRead,
                  child: Text(
                    'Mark all read',
                    style: TextStyle(
                      color: Colors.blue.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
      ],
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: ElevatedButton.icon(
          onPressed: _loadNotifications,
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      );
    }

    if (_notifications.isEmpty) {
      return const Center(child: Text('No notifications'));
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _notifications.length,
        itemBuilder: (_, i) =>
            _buildNotificationItem(_notifications[i], isDark),
      ),
    );
  }

  Widget _buildNotificationItem(
    NotificationModel notification,
    bool isDark,
  ) {
    return InkWell(
      onTap: () => _onNotificationTap(notification),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead
              ? (isDark ? const Color(0xFF1E1E1E) : Colors.white)
              : (isDark ? const Color(0xFF2A2A2A) : Colors.blue.shade50),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNotificationIcon(notification),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight:
                          notification.isRead ? FontWeight.w500 : FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatRelativeTime(notification.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationModel notification) {
    final type = NotificationType.fromString(notification.type);

    late IconData icon;
    late Color color;

    switch (type) {
      case NotificationType.job:
        icon = Icons.work_outline;
        color = Colors.blue;
        break;
      case NotificationType.message:
        icon = Icons.message_outlined;
        color = Colors.green;
        break;
      case NotificationType.system:
        icon = Icons.info_outline;
        color = Colors.orange;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color),
    );
  }

  String _formatRelativeTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
    return '${(diff.inDays / 365).floor()}y ago';
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}
