import 'package:flutter/material.dart';
import 'package:free_dz/screens/shared/message.dart';
import 'package:free_dz/services/api_helper.dart';
import 'package:free_dz/services/auth_service.dart';

class ConversationService {
  /// Starts (or gets) a conversation with a freelancer
  static Future<void> startConversation({
    required BuildContext context,
    required String freelancerId,
  }) async {
    try {
      debugPrint('Logged-in user ID: ${AuthService.currentUserId}');
      debugPrint('Target freelancer user ID: $freelancerId');

      final response = await ApiHelper.post(
        '/conversations',
        {
          'freelancer_id': freelancerId,
        },
      );

      final conversationId =
          response['data']?['id'] ?? response['conversationId'];

      if (conversationId == null) {
        throw Exception('Conversation ID not returned');
      }

      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ChatPage(conversationId: conversationId.toString()
              
              ),
        ),
      );
    } catch (e) {
      debugPrint('Start conversation error: $e');

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to start conversation'),
        ),
      );
    }
  }
}
