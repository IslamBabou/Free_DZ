import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:free_dz/models/chat_models.dart';
import 'dart:async';


// ==========================================
// CLIENT CHAT PAGE
// ==========================================

class ClientChatPage extends StatefulWidget {
  final String conversationId;
  final FreelancerInfo freelancer;

  const ClientChatPage({
    super.key,
    required this.conversationId,
    required this.freelancer,
  });

  @override
  State<ClientChatPage> createState() => _ClientChatPageState();
}

class _ClientChatPageState extends State<ClientChatPage> {
  // API Configuration
  static const String _apiBaseUrl = 'https://your-api.com/api';
  
  // State
  bool _isLoading = true;
  bool _hasError = false;
  bool _isBlocked = false;
  bool _isSending = false;
  List<ChatMessage> _messages = [];
  
  // Controllers
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  
  // Current user ID (should come from auth)
  final String _currentUserId = 'CLIENT_123';
  
  // Rate limiting
  DateTime? _lastMessageTime;
  static const _minMessageInterval = Duration(seconds: 1);
  
  // Polling timer for messages
  Timer? _messagePollingTimer;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _startMessagePolling();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messagePollingTimer?.cancel();
    super.dispose();
  }

  void _startMessagePolling() {
    // Poll for new messages every 3 seconds
    // TODO: Replace with WebSocket for production
    _messagePollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && !_isLoading) {
        _loadMessages(silent: true);
      }
    });
  }

  Future<void> _loadMessages({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }

    try {
      // TODO: Uncomment when API is ready
      /*
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/client/conversations/${widget.conversationId}/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_TOKEN',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> messagesJson = data['messages'];
        _messages = messagesJson.map((json) => ChatMessage.fromJson(json)).toList();
        _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        
        if (!silent) {
          setState(() => _isLoading = false);
        } else {
          setState(() {});
        }
        
        _scrollToBottom();
      } else if (response.statusCode == 401) {
        _redirectToLogin();
      } else if (response.statusCode == 403) {
        setState(() {
          _isBlocked = true;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load messages');
      }
      */

      // TEMPORARY: Mock data
      await Future.delayed(Duration(milliseconds: silent ? 100 : 1000));
      
      if (_messages.isEmpty) {
        _messages = [
          ChatMessage(
            id: '1',
            conversationId: widget.conversationId,
            senderId: widget.freelancer.id,
            senderRole: 'FREELANCER',
            content: 'Hello! Thank you for reaching out. How can I help you today?',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            status: MessageStatus.read,
            type: MessageType.text,
          ),
          ChatMessage(
            id: '2',
            conversationId: widget.conversationId,
            senderId: _currentUserId,
            senderRole: 'CLIENT',
            content: 'Hi! I\'m interested in your logo design service. Can you tell me more about your process?',
            timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 55)),
            status: MessageStatus.read,
            type: MessageType.text,
          ),
          ChatMessage(
            id: '3',
            conversationId: widget.conversationId,
            senderId: widget.freelancer.id,
            senderRole: 'FREELANCER',
            content: 'Of course! I start with understanding your brand, then create 3 initial concepts. We refine your favorite until you\'re completely satisfied.',
            timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 50)),
            status: MessageStatus.read,
            type: MessageType.text,
          ),
          ChatMessage(
            id: '4',
            conversationId: widget.conversationId,
            senderId: _currentUserId,
            senderRole: 'CLIENT',
            content: 'That sounds great! How long does the process usually take?',
            timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
            status: MessageStatus.read,
            type: MessageType.text,
          ),
          ChatMessage(
            id: '5',
            conversationId: widget.conversationId,
            senderId: widget.freelancer.id,
            senderRole: 'FREELANCER',
            content: 'Typically 5-7 business days from start to final delivery. I can work with rush timelines if needed.',
            timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
            status: MessageStatus.delivered,
            type: MessageType.text,
          ),
        ];
      }
      
      if (!silent) {
        setState(() => _isLoading = false);
      }
      _scrollToBottom();
    } catch (e) {
      debugPrint('Error loading messages: $e');
      if (!silent) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isSending || _isBlocked) return;

    // Rate limiting
    if (_lastMessageTime != null) {
      final timeSinceLastMessage = DateTime.now().difference(_lastMessageTime!);
      if (timeSinceLastMessage < _minMessageInterval) {
        _showSnackBar('Please wait a moment before sending another message', isError: true);
        return;
      }
    }

    // Sanitize input
    final sanitizedContent = content.replaceAll(RegExp(r'<[^>]*>'), '');

    setState(() => _isSending = true);
    _messageController.clear();

    // Optimistic UI update
    final tempMessage = ChatMessage(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: widget.conversationId,
      senderId: _currentUserId,
      senderRole: 'CLIENT',
      content: sanitizedContent,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
      type: MessageType.text,
    );

    setState(() {
      _messages.add(tempMessage);
      _lastMessageTime = DateTime.now();
    });
    _scrollToBottom();

    try {
      // TODO: Uncomment when API is ready
      /*
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/client/conversations/${widget.conversationId}/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_TOKEN',
        },
        body: json.encode({
          'content': sanitizedContent,
          'type': 'text',
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final sentMessage = ChatMessage.fromJson(data);
        
        setState(() {
          _messages.removeWhere((m) => m.id == tempMessage.id);
          _messages.add(sentMessage);
        });
      } else {
        throw Exception('Failed to send message');
      }
      */

      // TEMPORARY: Mock send
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        final index = _messages.indexWhere((m) => m.id == tempMessage.id);
        if (index != -1) {
          _messages[index] = ChatMessage(
            id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
            conversationId: tempMessage.conversationId,
            senderId: tempMessage.senderId,
            senderRole: tempMessage.senderRole,
            content: tempMessage.content,
            timestamp: tempMessage.timestamp,
            status: MessageStatus.sent,
            type: tempMessage.type,
          );
        }
      });
    } catch (e) {
      debugPrint('Error sending message: $e');
      setState(() {
        final index = _messages.indexWhere((m) => m.id == tempMessage.id);
        if (index != -1) {
          _messages[index] = ChatMessage(
            id: tempMessage.id,
            conversationId: tempMessage.conversationId,
            senderId: tempMessage.senderId,
            senderRole: tempMessage.senderRole,
            content: tempMessage.content,
            timestamp: tempMessage.timestamp,
            status: MessageStatus.failed,
            type: tempMessage.type,
          );
        }
      });
      _showSnackBar('Failed to send message', isError: true);
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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

  void _redirectToLogin() {
    // TODO: Implement navigation to login
    debugPrint('Redirecting to login...');
  }

  Future<void> _showActionMenu() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.report_outlined, color: Colors.orange),
              title: const Text('Report Conversation'),
              onTap: () {
                Navigator.pop(context);
                _showReportDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: const Text('Block Freelancer'),
              onTap: () {
                Navigator.pop(context);
                _showBlockDialog();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _showReportDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Conversation'),
        content: const Text('Are you sure you want to report this conversation? Our team will review it.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Report submitted. Thank you.');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  Future<void> _showBlockDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block Freelancer'),
        content: const Text('Are you sure you want to block this freelancer? You won\'t be able to receive messages from them.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Block'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isBlocked = true);
      _showSnackBar('Freelancer blocked', isError: false);
    }
  }

  void _onMessageLongPress(ChatMessage message) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy Message'),
              onTap: () {
                Clipboard.setData(ClipboardData(text: message.content));
                Navigator.pop(context);
                _showSnackBar('Message copied');
              },
            ),
            if (message.senderRole != 'CLIENT')
              ListTile(
                leading: const Icon(Icons.report_outlined, color: Colors.red),
                title: const Text('Report Message'),
                onTap: () {
                  Navigator.pop(context);
                  _showSnackBar('Message reported');
                },
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade50,
      appBar: _buildAppBar(isDark),
      body: _buildBody(isDark),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      elevation: 1,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back),
      ),
      title: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue.shade100,
                child: widget.freelancer.avatarUrl != null
                    ? ClipOval(
                        child: Image.network(
                          widget.freelancer.avatarUrl!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.person, color: Colors.blue.shade700);
                          },
                        ),
                      )
                    : Icon(Icons.person, color: Colors.blue.shade700),
              ),
              if (widget.freelancer.isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.freelancer.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.freelancer.isOnline
                      ? 'Online'
                      : widget.freelancer.lastSeen != null
                          ? 'Last seen ${_formatLastSeen(widget.freelancer.lastSeen!)}'
                          : 'Offline',
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.freelancer.isOnline ? Colors.green : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _showActionMenu,
          icon: const Icon(Icons.more_vert),
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
            const Text('Failed to load messages', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadMessages,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (_isBlocked)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.red.shade100,
            child: Row(
              children: [
                Icon(Icons.block, color: Colors.red.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This conversation is blocked. You can no longer send messages.',
                    style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: _messages.isEmpty
              ? Center(
                  child: Text(
                    'No messages yet. Start the conversation!',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessageBubble(_messages[index], isDark);
                  },
                ),
        ),
        _buildInputBar(isDark),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isDark) {
    final isMe = message.senderRole == 'CLIENT';
    final showTimestamp = _shouldShowTimestamp(message);

    return Column(
      children: [
        if (showTimestamp) _buildTimestampDivider(message.timestamp, isDark),
        GestureDetector(
          onLongPress: () => _onMessageLongPress(message),
          child: Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: isMe
                    ? Colors.blue
                    : (isDark ? Colors.grey.shade800 : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 15,
                      color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: isMe ? Colors.white70 : Colors.grey.shade600,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        _buildMessageStatusIcon(message.status),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimestampDivider(DateTime timestamp, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _formatDate(timestamp),
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return Icon(Icons.access_time, size: 14, color: Colors.white70);
      case MessageStatus.sent:
        return Icon(Icons.check, size: 14, color: Colors.white70);
      case MessageStatus.delivered:
        return Icon(Icons.done_all, size: 14, color: Colors.white70);
      case MessageStatus.read:
        return Icon(Icons.done_all, size: 14, color: Colors.blue.shade200);
      case MessageStatus.failed:
        return Icon(Icons.error_outline, size: 14, color: Colors.red.shade200);
    }
  }

  Widget _buildInputBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                enabled: !_isBlocked,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: _isBlocked ? 'Chat is blocked' : 'Type a message...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  filled: true,
                  fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  prefixIcon: IconButton(
                    onPressed: _isBlocked ? null : () {
                      // TODO: Implement file/image attachment
                      _showSnackBar('Attachment feature coming soon');
                    },
                    icon: Icon(Icons.attach_file, color: Colors.grey.shade600),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: (_isBlocked || _isSending) ? null : _sendMessage,
                icon: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _shouldShowTimestamp(ChatMessage message) {
    final index = _messages.indexOf(message);
    if (index == 0) return true;

    final previousMessage = _messages[index - 1];
    final difference = message.timestamp.difference(previousMessage.timestamp);
    
    return difference.inMinutes > 30;
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      return days[date.weekday - 1];
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatLastSeen(DateTime lastSeen) {
    final difference = DateTime.now().difference(lastSeen);
    
    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}