import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:free_dz/models/chat_models.dart';
import 'package:free_dz/services/api_helper.dart';
import 'dart:async';

// ==========================================
// CHAT PAGE - IMPROVED
// ==========================================

class ChatPage extends StatefulWidget {
  final String conversationId;

  const ChatPage({
    super.key,
    required this.conversationId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  // Peer info
  String _peerName = '';
  String? _peerAvatarUrl;
  bool _isOnline = false;
  DateTime? _lastSeen;
  
  // State
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  bool _isBlocked = false;
  bool _isSending = false;
  List<ChatMessage> _messages = [];
  
  // Controllers
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  
  // Current user ID - inferred from messages
  String? _currentUserId;
  
  // Rate limiting
  DateTime? _lastMessageTime;
  static const _minMessageInterval = Duration(seconds: 1);
  
  // Polling timer for messages
  Timer? _messagePollingTimer;
  
  // Typing indicator
  bool _isTyping = false;
  Timer? _typingTimer;
  
  // Connectivity
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeChat();
    _setupMessageListener();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _messagePollingTimer?.cancel();
    _typingTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadConversation(silent: true);
    }
  }

  void _setupMessageListener() {
    _messageController.addListener(() {
      if (_messageController.text.isNotEmpty && !_isTyping) {
        setState(() => _isTyping = true);
      }
      
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) setState(() => _isTyping = false);
      });
    });
  }

  Future<void> _initializeChat() async {
    await _loadConversation();
    _startMessagePolling();
  }

  void _startMessagePolling() {
    _messagePollingTimer?.cancel();
    _messagePollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && !_isLoading) {
        _loadConversation(silent: true);
      }
    });
  }

  Future<void> _loadConversation({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = null;
      });
    }

    try {
      final data = await ApiHelper.get(
        '/conversations/${widget.conversationId}/messages',
      );

      if (!mounted) return;

      // Parse response
      final parsedData = _parseConversationData(data);
      
      setState(() {
        _messages = parsedData.messages;
        _peerName = parsedData.peerName;
        _peerAvatarUrl = parsedData.peerAvatarUrl;
        _isOnline = parsedData.isOnline;
        _lastSeen = parsedData.lastSeen;
        _currentUserId = parsedData.currentUserId;
        _isBlocked = parsedData.isBlocked;
        _isLoading = false;
        _isConnected = true;
      });

      if (!silent && _messages.isNotEmpty) {
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Load conversation error: $e');
      if (!mounted) return;
      
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
        _isConnected = false;
      });
    }
  }

  _ConversationData _parseConversationData(dynamic data) {
    List<dynamic> messagesJson = [];
    String peerName = '';
    String? peerAvatarUrl;
    bool isOnline = false;
    DateTime? lastSeen;
    String? currentUserId;
    bool isBlocked = false;

    // Handle different response formats
    if (data is List) {
      messagesJson = data;
    } else if (data is Map) {
      messagesJson = data['messages'] ?? data['data'] ?? [];
      isBlocked = data['is_blocked'] ?? data['isBlocked'] ?? false;
      
      // Extract peer info from various possible locations
      final peerData = data['peer'] ?? data['freelancer'] ?? data['other_user'];
      if (peerData != null) {
        peerName = peerData['name'] ?? 
                   peerData['full_name'] ?? 
                   peerData['fullName'] ?? 
                   'Unknown';
        peerAvatarUrl = peerData['avatar_url'] ?? 
                       peerData['avatarUrl'] ?? 
                       peerData['avatar'];
        isOnline = peerData['is_online'] ?? 
                   peerData['isOnline'] ?? 
                   peerData['online'] ?? 
                   false;
        final lastSeenStr = peerData['last_seen'] ?? 
                           peerData['lastSeen'] ?? 
                           peerData['last_active'];
        if (lastSeenStr != null) {
          lastSeen = DateTime.tryParse(lastSeenStr.toString());
        }
      }

      // Get current user ID from metadata
      currentUserId = data['current_user_id'] ?? 
                     data['currentUserId'] ?? 
                     data['user_id'];
    }

    // Parse messages
    final messages = messagesJson
        .map((json) => ChatMessage.fromJson(json))
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Infer current user ID and peer info from messages if not available
    if (messages.isNotEmpty) {
      // Try to infer current user ID from message pattern
      if (currentUserId == null) {
        final senderIds = messages.map((m) => m.senderId).toSet();
        if (senderIds.length == 2) {
          // In a conversation, find the ID that appears most as sender
          final senderCounts = <String, int>{};
          for (final msg in messages) {
            senderCounts[msg.senderId] = (senderCounts[msg.senderId] ?? 0) + 1;
          }
          // Assume current user is the one who sent messages most recently
          currentUserId = messages.last.senderId;
        } else if (senderIds.length == 1) {
          // Only one person sent messages (likely current user)
          currentUserId = senderIds.first;
        }
      }

      // Extract peer info from first message if still not available
      if (peerName.isEmpty) {
        final firstMsg = messages.first;
        peerName = firstMsg.senderRole == 'FREELANCER' 
            ? (firstMsg.content.split(':').first) 
            : 'Unknown';
      }
    }

    return _ConversationData(
      messages: messages,
      peerName: peerName,
      peerAvatarUrl: peerAvatarUrl,
      isOnline: isOnline,
      lastSeen: lastSeen,
      currentUserId: currentUserId,
      isBlocked: isBlocked,
    );
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isSending || _isBlocked) {
      return;
    }

    // Rate limiting
    if (_lastMessageTime != null) {
      final timeSinceLastMessage = DateTime.now().difference(_lastMessageTime!);
      if (timeSinceLastMessage < _minMessageInterval) {
        _showSnackBar(
          'Please wait a moment before sending another message',
          isError: true,
        );
        return;
      }
    }

    // Sanitize input
    final sanitizedContent = content
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (sanitizedContent.isEmpty) {
      _showSnackBar('Cannot send empty message', isError: true);
      return;
    }

    setState(() => _isSending = true);
    _messageController.clear();
    _focusNode.unfocus();

    // Infer current user ID if not available
    final userId = _currentUserId ?? 'temp_user';

    // Optimistic UI update
    final tempMessage = ChatMessage(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: widget.conversationId,
      senderId: userId,
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
      final response = await ApiHelper.post(
        '/conversations/${widget.conversationId}/messages',
        {
          'content': sanitizedContent,
          'type': 'text',
        },
      );

      final sentMessage = ChatMessage.fromJson(
        response['data'] ?? response['message'] ?? response,
      );

      if (!mounted) return;

      setState(() {
        _messages.removeWhere((m) => m.id == tempMessage.id);
        _messages.add(sentMessage);
        
        // Update current user ID from sent message
        if (_currentUserId == null || _currentUserId == 'temp_user') {
          _currentUserId = sentMessage.senderId;
        }
      });
      
      _scrollToBottom();
    } catch (e) {
      debugPrint('Error sending message: $e');
      if (!mounted) return;

      // Update message status to failed
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
      
      _showSnackBar('Failed to send message. Tap to retry.', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _retryFailedMessage(ChatMessage message) async {
    if (message.status != MessageStatus.failed) return;

    setState(() {
      final index = _messages.indexWhere((m) => m.id == message.id);
      if (index != -1) {
        _messages[index] = ChatMessage(
          id: message.id,
          conversationId: message.conversationId,
          senderId: message.senderId,
          senderRole: message.senderRole,
          content: message.content,
          timestamp: message.timestamp,
          status: MessageStatus.sending,
          type: message.type,
        );
      }
    });

    try {
      final response = await ApiHelper.post(
        '/conversations/${widget.conversationId}/messages',
        {
          'content': message.content,
          'type': 'text',
        },
      );

      final sentMessage = ChatMessage.fromJson(
        response['data'] ?? response['message'] ?? response,
      );

      if (!mounted) return;

      setState(() {
        _messages.removeWhere((m) => m.id == message.id);
        _messages.add(sentMessage);
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        final index = _messages.indexWhere((m) => m.id == message.id);
        if (index != -1) {
          _messages[index] = ChatMessage(
            id: message.id,
            conversationId: message.conversationId,
            senderId: message.senderId,
            senderRole: message.senderRole,
            content: message.content,
            timestamp: message.timestamp,
            status: MessageStatus.failed,
            type: message.type,
          );
        }
      });
      
      _showSnackBar('Failed to send message', isError: true);
    }
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      
      if (animated) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  Future<void> _showActionMenu() async {
    HapticFeedback.lightImpact();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(Icons.info_outline, color: Colors.blue.shade700),
                title: const Text('Conversation Info'),
                subtitle: Text('ID: ${widget.conversationId}'),
                onTap: () => Navigator.pop(context),
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.report_outlined, color: Colors.orange.shade700),
                title: const Text('Report Conversation'),
                onTap: () {
                  Navigator.pop(context);
                  _showReportDialog();
                },
              ),
              ListTile(
                leading: Icon(Icons.block, color: Colors.red.shade700),
                title: Text(_isBlocked ? 'Unblock User' : 'Block User'),
                onTap: () {
                  Navigator.pop(context);
                  _showBlockDialog();
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showReportDialog() async {
    final reasons = [
      'Spam',
      'Harassment',
      'Inappropriate content',
      'Scam or fraud',
      'Other',
    ];
    
    String? selectedReason;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Report Conversation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Why are you reporting this conversation?'),
              const SizedBox(height: 16),
              ...reasons.map((reason) => RadioListTile<String>(
                title: Text(reason),
                value: reason,
                groupValue: selectedReason,
                onChanged: (value) => setState(() => selectedReason = value),
                contentPadding: EdgeInsets.zero,
              )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: selectedReason == null
                  ? null
                  : () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Report'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && selectedReason != null) {
      _showSnackBar('Report submitted. Thank you.');
    }
  }

  Future<void> _showBlockDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(_isBlocked ? 'Unblock User' : 'Block User'),
        content: Text(
          _isBlocked
              ? 'Are you sure you want to unblock this user? You will be able to receive messages from them again.'
              : 'Are you sure you want to block this user? You won\'t be able to receive messages from them.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: _isBlocked ? Colors.green : Colors.red,
            ),
            child: Text(_isBlocked ? 'Unblock' : 'Block'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isBlocked = !_isBlocked);
      _showSnackBar(_isBlocked ? 'User blocked' : 'User unblocked');
    }
  }

  void _onMessageLongPress(ChatMessage message) {
    HapticFeedback.mediumImpact();
    
    final isMe = message.senderId == _currentUserId;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy Message'),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: message.content));
                  Navigator.pop(context);
                  _showSnackBar('Message copied');
                },
              ),
              if (message.status == MessageStatus.failed && isMe)
                ListTile(
                  leading: const Icon(Icons.refresh, color: Colors.blue),
                  title: const Text('Retry'),
                  onTap: () {
                    Navigator.pop(context);
                    _retryFailedMessage(message);
                  },
                ),
              if (!isMe)
                ListTile(
                  leading: Icon(Icons.report_outlined, color: Colors.red.shade700),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : Colors.grey.shade50,
      appBar: _buildAppBar(isDark),
      body: Column(
        children: [
          if (!_isConnected)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.orange.shade100,
              child: Row(
                children: [
                  Icon(Icons.wifi_off, color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Connection lost. Trying to reconnect...',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _loadConversation,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          if (_isBlocked)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.red.shade50,
              child: Row(
                children: [
                  Icon(Icons.block, color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This conversation is blocked. You can no longer send or receive messages.',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(child: _buildBody(isDark)),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withOpacity(0.1),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back),
        tooltip: 'Back',
      ),
      title: _peerName.isNotEmpty
          ? InkWell(
              onTap: _showActionMenu,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _isOnline 
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.blue.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.blue.shade100,
                            backgroundImage: _peerAvatarUrl != null && 
                                           _peerAvatarUrl!.isNotEmpty
                                ? NetworkImage(_peerAvatarUrl!)
                                : null,
                            child: _peerAvatarUrl == null || _peerAvatarUrl!.isEmpty
                                ? Icon(Icons.person, color: Colors.blue.shade700)
                                : null,
                          ),
                        ),
                        if (_isOnline)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF1E1E1E)
                                      : Colors.white,
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
                            _peerName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _isOnline
                                ? 'Online'
                                : _lastSeen != null
                                    ? 'Last seen ${_formatLastSeen(_lastSeen!)}'
                                    : 'Offline',
                            style: TextStyle(
                              fontSize: 12,
                              color: _isOnline
                                  ? Colors.green
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const Text('Chat'),
      actions: [
        if (_peerName.isNotEmpty)
          IconButton(
            onPressed: _showActionMenu,
            icon: const Icon(Icons.more_vert),
            tooltip: 'More options',
          ),
      ],
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.blue.shade600,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading conversation...',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.orange.shade400,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Failed to load messages',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadConversation,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: _messages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No messages yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start the conversation!',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
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
    final isMe = message.senderId == _currentUserId;
    final showTimestamp = _shouldShowTimestamp(message);
    final isFailed = message.status == MessageStatus.failed;

    return Column(
      children: [
        if (showTimestamp) _buildTimestampDivider(message.timestamp, isDark),
        GestureDetector(
          onLongPress: () => _onMessageLongPress(message),
          onTap: isFailed && isMe ? () => _retryFailedMessage(message) : null,
          child: Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                gradient: isMe && !isFailed
                    ? LinearGradient(
                        colors: [
                          Colors.blue.shade600,
                          Colors.blue.shade500,
                        ],
                      )
                    : null,
                color: isMe
                    ? (isFailed ? Colors.red.shade100 : null)
                    : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                border: isFailed
                    ? Border.all(color: Colors.red.shade300, width: 1)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
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
                      color: isMe
                          ? (isFailed ? Colors.red.shade900 : Colors.white)
                          : (isDark ? Colors.white : Colors.black87),
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
                          color: isMe
                              ? (isFailed 
                                  ? Colors.red.shade700 
                                  : Colors.white.withOpacity(0.8))
                              : Colors.grey.shade600,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        _buildMessageStatusIcon(message.status, isFailed),
                      ],
                    ],
                  ),
                  if (isFailed) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Tap to retry',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.red.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
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
            color: isDark
                ? Colors.grey.shade800.withOpacity(0.5)
                : Colors.grey.shade200,
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

  Widget _buildMessageStatusIcon(MessageStatus status, bool isFailed) {
    if (isFailed) {
      return Icon(Icons.error_outline, size: 14, color: Colors.red.shade700);
    }

    switch (status) {
      case MessageStatus.sending:
        return SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white.withOpacity(0.8),
          ),
        );
      case MessageStatus.sent:
        return Icon(Icons.check, size: 14, color: Colors.white.withOpacity(0.8));
      case MessageStatus.delivered:
        return Icon(Icons.done_all, size: 14, color: Colors.white.withOpacity(0.8));
      case MessageStatus.read:
        return Icon(Icons.done_all, size: 14, color: Colors.blue.shade200);
      case MessageStatus.failed:
        return Icon(Icons.error_outline, size: 14, color: Colors.red.shade200);
    }
  }

  Widget _buildInputBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0D1117) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  focusNode: _focusNode,
                  enabled: !_isBlocked,
                  maxLines: 5,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: _isBlocked 
                        ? 'Chat is blocked' 
                        : 'Type a message...',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                gradient: (_isBlocked || _isSending)
                    ? null
                    : LinearGradient(
                        colors: [Colors.blue.shade600, Colors.blue.shade500],
                      ),
                color: (_isBlocked || _isSending) 
                    ? Colors.grey.shade400 
                    : null,
                shape: BoxShape.circle,
                boxShadow: (_isBlocked || _isSending)
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
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
                    : const Icon(Icons.send, color: Colors.white, size: 20),
                tooltip: _isBlocked ? 'Chat is blocked' : 'Send message',
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
      const days = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
      ];
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
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return 'a while ago';
    }
  }
}

// Helper class for parsing conversation data
class _ConversationData {
  final List<ChatMessage> messages;
  final String peerName;
  final String? peerAvatarUrl;
  final bool isOnline;
  final DateTime? lastSeen;
  final String? currentUserId;
  final bool isBlocked;

  _ConversationData({
    required this.messages,
    required this.peerName,
    this.peerAvatarUrl,
    required this.isOnline,
    this.lastSeen,
    this.currentUserId,
    required this.isBlocked,
  });
}