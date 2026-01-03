import 'package:flutter/material.dart';
import 'package:free_dz/models/notifications.dart';
import 'package:free_dz/services/api_helper.dart';

// ==========================================
// FREELANCER NOTIFICATIONS PAGE
// ==========================================

class FreelancerNotificationsPage extends StatefulWidget {
  const FreelancerNotificationsPage({super.key});

  @override
  State<FreelancerNotificationsPage> createState() => _FreelancerNotificationsPageState();
}

class _FreelancerNotificationsPageState extends State<FreelancerNotificationsPage> {
  // State
  bool _isLoading = true;
  bool _hasError = false;
  List<NotificationModel> _notifications = [];
  bool _isMarkingAllAsRead = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final data = await ApiHelper.get('/freelancer/notifications');
      
      final List<dynamic> notificationsJson =
    data is List
        ? data
        : (data['notifications'] as List? ?? []);
        
      _notifications = notificationsJson
          .map((json) => NotificationModel.fromJson(json))
          .toList();
      
      // Sort by date, most recent first
      _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      setState(() => _isLoading = false);
    } on Exception catch (e) {
      final errorMsg = e.toString();
      
      if (errorMsg.contains('Unauthorized')) {
        _redirectToLogin();
      } else {
        debugPrint('Error loading notifications: $e');
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markNotificationAsRead(NotificationModel notification) async {
    if (notification.isRead) return;

    // Optimistic update
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        _notifications[index] = notification.copyWith(isRead: true);
      }
    });

    try {
      await ApiHelper.put('/freelancer/notifications/${notification.id}/read', {});
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      // Revert on failure
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          _notifications[index] = notification;
        }
      });
    }
  }

  Future<void> _markAllAsRead() async {
    final unreadNotifications = _notifications.where((n) => !n.isRead).toList();
    if (unreadNotifications.isEmpty) return;

    setState(() => _isMarkingAllAsRead = true);

    try {
      await ApiHelper.put('/freelancer/notifications/read-all', {});
      
      setState(() {
        _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
        _isMarkingAllAsRead = false;
      });
      
      _showSnackBar('All notifications marked as read');
    } catch (e) {
      debugPrint('Error marking all as read: $e');
      setState(() => _isMarkingAllAsRead = false);
      _showSnackBar('Failed to mark all as read', isError: true);
    }
  }

  void _onNotificationTap(NotificationModel notification) {
    _markNotificationAsRead(notification);
    
    // Navigate based on notification type
    // TODO: Implement actual navigation logic
    switch (notification.type) {
      case NotificationType.job:
        debugPrint('Navigate to job details');
        // Navigator.pushNamed(context, '/job-details', arguments: notification.id);
        break;
      case NotificationType.message:
        debugPrint('Navigate to messages');
        // Navigator.pushNamed(context, '/messages');
        break;
      case NotificationType.system:
        debugPrint('System notification tapped');
        break;
    }
  }

  void _redirectToLogin() {
    debugPrint('Redirecting to login...');
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasUnreadNotifications = _notifications.any((n) => !n.isRead);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade50,
      appBar: _buildAppBar(isDark, hasUnreadNotifications),
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
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        if (!_isLoading && hasUnread)
          _isMarkingAllAsRead
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.orange.shade400),
            const SizedBox(height: 16),
            const Text(
              'Failed to load notifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your connection and try again',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadNotifications,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 100,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You\'ll receive updates about jobs,\nmessages, and more here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.builder(
        itemCount: _notifications.length,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          return _buildNotificationItem(
            _notifications[index],
            isDark,
            index,
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(
    NotificationModel notification,
    bool isDark,
    int index,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: InkWell(
        onTap: () => _onNotificationTap(notification),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead
                ? (isDark ? const Color(0xFF1E1E1E) : Colors.white)
                : (isDark ? const Color(0xFF2A2A2A) : Colors.blue.shade50),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: notification.isRead
                  ? (isDark ? Colors.grey.shade800 : Colors.grey.shade200)
                  : Colors.blue.shade200,
              width: notification.isRead ? 0.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNotificationIcon(notification, isDark),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade600,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatRelativeTime(notification.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationModel notification, bool isDark) {
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case NotificationType.job:
        iconData = Icons.work_outline;
        iconColor = Colors.blue;
        break;
      case NotificationType.message:
        iconData = Icons.message_outlined;
        iconColor = Colors.green;
        break;
      case NotificationType.system:
        iconData = Icons.info_outline;
        iconColor = Colors.orange;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 24,
      ),
    );
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '${minutes}m ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '${hours}h ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '${days}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    }
  }
}