
// ==========================================
// ENUMS
// ==========================================

// ignore_for_file: unnecessary_this

enum MessageStatus { 
  sending, 
  sent, 
  delivered, 
  read, 
  failed 
}

enum MessageType { 
  text, 
  image, 
  file 
}

enum UserRole {
  client,
  freelancer,
  admin
}

// ==========================================
// FREELANCER INFO MODEL
// ==========================================

class FreelancerInfo {
  final String id;
  final String name;
  final String? avatarUrl;
  final bool isOnline;
  final DateTime? lastSeen;

  FreelancerInfo({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.isOnline,
    this.lastSeen,
  });

  factory FreelancerInfo.fromJson(Map<String, dynamic> json) {
    return FreelancerInfo(
      id: json['id'].toString(),
      name: json['name'] ?? 'Unknown',
      avatarUrl: json['avatarUrl'] ?? json['avatar'],
      isOnline: json['isOnline'] ?? false,
      lastSeen: json['lastSeen'] != null 
          ? DateTime.parse(json['lastSeen']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'isOnline': isOnline,
      'lastSeen': lastSeen?.toIso8601String(),
    };
  }

  FreelancerInfo copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    bool? isOnline,
    DateTime? lastSeen,
  }) {
    return FreelancerInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FreelancerInfo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'FreelancerInfo(id: $id, name: $name, isOnline: $isOnline)';
  }
}

// ==========================================
// CONVERSATION MODEL
// ==========================================

class Conversation {
  final String id;
  final String peerId;
  final String peerName;
  final String? peerAvatarUrl;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  Conversation({
    required this.id,
    required this.peerId,
    required this.peerName,
    this.peerAvatarUrl,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    final peer = json['peer'] ?? {};
    return Conversation(
      id: json['id'].toString(),
      peerId: peer['id'].toString(),
      peerName: peer['name'] ?? 'Unknown',
      peerAvatarUrl: peer['avatarUrl'],
      lastMessage: json['lastMessage'] ?? '',
      lastMessageTime: DateTime.parse(json['lastMessageTime']),
      unreadCount: json['unreadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'peer': {
        'id': peerId,
        'name': peerName,
        'avatarUrl': peerAvatarUrl,
      },
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'unreadCount': unreadCount,
    };
  }

  Conversation copyWith({
    String? id,
    FreelancerInfo? freelancer,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    bool? isOnline,
  }) {
    return Conversation(
      id: id ?? this.id,
      peerId: freelancer?.id ?? this.peerId,
      peerName: freelancer?.name ?? this.peerName,
      peerAvatarUrl: freelancer?.avatarUrl ?? this.peerAvatarUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Conversation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  
}

// ==========================================
// CHAT MESSAGE MODEL
// ==========================================

class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderRole;
  final String content;
  final DateTime timestamp;
  final MessageStatus status;
  final MessageType type;
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderRole,
    required this.content,
    required this.timestamp,
    required this.status,
    required this.type,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    this.metadata,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'].toString(),
      conversationId: json['conversationId'].toString(),
      senderId: json['senderId'].toString(),
      senderRole: json['senderRole'] ?? 'CLIENT',
      content: json['content'] ?? '',
      timestamp: DateTime.parse(
        json['timestamp'] ?? DateTime.now().toIso8601String()
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'sent'),
        orElse: () => MessageStatus.sent,
      ),
      type: MessageType.values.firstWhere(
        (e) => e.name == (json['type'] ?? 'text'),
        orElse: () => MessageType.text,
      ),
      fileUrl: json['fileUrl'],
      fileName: json['fileName'],
      fileSize: json['fileSize'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'senderRole': senderRole,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'type': type.name,
      if (fileUrl != null) 'fileUrl': fileUrl,
      if (fileName != null) 'fileName': fileName,
      if (fileSize != null) 'fileSize': fileSize,
      if (metadata != null) 'metadata': metadata,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderRole,
    String? content,
    DateTime? timestamp,
    MessageStatus? status,
    MessageType? type,
    String? fileUrl,
    String? fileName,
    int? fileSize,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderRole: senderRole ?? this.senderRole,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      type: type ?? this.type,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isFromClient => senderRole.toUpperCase() == 'CLIENT';
  
  bool get isFromFreelancer => senderRole.toUpperCase() == 'FREELANCER';
  
  bool get hasFile => fileUrl != null && fileUrl!.isNotEmpty;
  
  bool get isPending => status == MessageStatus.sending;
  
  bool get isFailed => status == MessageStatus.failed;
  
  bool get isDelivered => 
      status == MessageStatus.delivered || status == MessageStatus.read;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ChatMessage(id: $id, sender: $senderRole, status: ${status.name}, type: ${type.name})';
  }
}

class ChatUser {
  final String id;
  final String name;
  final String? avatarUrl;
  final bool isOnline;
  final DateTime? lastSeen;

  ChatUser({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.isOnline,
    this.lastSeen,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'].toString(),
      name: json['name'] ?? 'Unknown',
      avatarUrl: json['avatarUrl'],
      isOnline: json['isOnline'] ?? false,
      lastSeen: json['lastSeen'] != null
          ? DateTime.parse(json['lastSeen'])
          : null,
    );
  }
}


// ==========================================
// TYPING INDICATOR MODEL
// ==========================================

class TypingIndicator {
  final String userId;
  final String userName;
  final DateTime timestamp;

  TypingIndicator({
    required this.userId,
    required this.userName,
    required this.timestamp,
  });

  factory TypingIndicator.fromJson(Map<String, dynamic> json) {
    return TypingIndicator(
      userId: json['userId'].toString(),
      userName: json['userName'] ?? 'Unknown',
      timestamp: DateTime.parse(
        json['timestamp'] ?? DateTime.now().toIso8601String()
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  bool isExpired({Duration timeout = const Duration(seconds: 5)}) {
    return DateTime.now().difference(timestamp) > timeout;
  }
}

// ==========================================
// MESSAGE RECEIPT MODEL (for read receipts)
// ==========================================

class MessageReceipt {
  final String messageId;
  final String userId;
  final MessageStatus status;
  final DateTime timestamp;

  MessageReceipt({
    required this.messageId,
    required this.userId,
    required this.status,
    required this.timestamp,
  });

  factory MessageReceipt.fromJson(Map<String, dynamic> json) {
    return MessageReceipt(
      messageId: json['messageId'].toString(),
      userId: json['userId'].toString(),
      status: MessageStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MessageStatus.sent,
      ),
      timestamp: DateTime.parse(
        json['timestamp'] ?? DateTime.now().toIso8601String()
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'userId': userId,
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

// ==========================================
// CONVERSATION METADATA MODEL
// ==========================================

class ConversationMetadata {
  final String conversationId;
  final bool isMuted;
  final bool isArchived;
  final bool isBlocked;
  final DateTime? mutedUntil;
  final List<String>? pinnedMessages;

  ConversationMetadata({
    required this.conversationId,
    this.isMuted = false,
    this.isArchived = false,
    this.isBlocked = false,
    this.mutedUntil,
    this.pinnedMessages,
  });

  factory ConversationMetadata.fromJson(Map<String, dynamic> json) {
    return ConversationMetadata(
      conversationId: json['conversationId'].toString(),
      isMuted: json['isMuted'] ?? false,
      isArchived: json['isArchived'] ?? false,
      isBlocked: json['isBlocked'] ?? false,
      mutedUntil: json['mutedUntil'] != null 
          ? DateTime.parse(json['mutedUntil']) 
          : null,
      pinnedMessages: json['pinnedMessages'] != null
          ? List<String>.from(json['pinnedMessages'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'isMuted': isMuted,
      'isArchived': isArchived,
      'isBlocked': isBlocked,
      if (mutedUntil != null) 'mutedUntil': mutedUntil!.toIso8601String(),
      if (pinnedMessages != null) 'pinnedMessages': pinnedMessages,
    };
  }

  ConversationMetadata copyWith({
    String? conversationId,
    bool? isMuted,
    bool? isArchived, 
    bool? isBlocked,
    DateTime? mutedUntil,
    List<String>? pinnedMessages,
  }) {
    return ConversationMetadata(
      conversationId: conversationId ?? this.conversationId,
      isMuted: isMuted ?? this.isMuted,
      isArchived: isArchived ?? this.isArchived,
      isBlocked: isBlocked ?? this.isBlocked,
      mutedUntil: mutedUntil ?? this.mutedUntil,
      pinnedMessages: pinnedMessages ?? this.pinnedMessages,
    );
  }
}

// ==========================================
// HELPER EXTENSIONS
// ==========================================

extension MessageStatusExtension on MessageStatus {
  String get displayName {
    switch (this) {
      case MessageStatus.sending:
        return 'Sending';
      case MessageStatus.sent:
        return 'Sent';
      case MessageStatus.delivered:
        return 'Delivered';
      case MessageStatus.read:
        return 'Read';
      case MessageStatus.failed:
        return 'Failed';
    }
  }

  bool get isSuccessful => this != MessageStatus.failed;
}

extension MessageTypeExtension on MessageType {
  String get displayName {
    switch (this) {
      case MessageType.text:
        return 'Text';
      case MessageType.image:
        return 'Image';
      case MessageType.file:
        return 'File';
    }
  }

  String get icon {
    switch (this) {
      case MessageType.text:
        return '💬';
      case MessageType.image:
        return '🖼️';
      case MessageType.file:
        return '📎';
    }
  }
}