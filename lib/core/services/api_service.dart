import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  final String baseUrl = 'http://localhost:8080/api';
  final SupabaseClient supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> sendChatMessage(String prompt) async {
    try {
      final session = supabase.auth.currentSession;

      if (session == null) {
        throw Exception('Not authenticated');
      }

      final accessToken = session.accessToken;

      final response = await http.post(
        Uri.parse('$baseUrl/generate/health'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'prompt': prompt,
          'user_id': session.user.id,
        }),
      );

      if (response.statusCode == 401) {
        final newSession = await supabase.auth.refreshSession();
        if (newSession != null) {
          return sendChatMessage(prompt);
        }
        throw Exception('Authentication failed');
      }

      if (response.statusCode != 200) {
        throw Exception('Failed to send message: ${response.body}');
      }

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  Future<Map<String, dynamic>> memorizeChat(String prompt) async {
    try {
      final session = supabase.auth.currentSession;

      if (session == null) {
        throw Exception('Not authenticated');
      }

      final accessToken = session.accessToken;

      final response = await http.post(
        Uri.parse('$baseUrl/generate/memory'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'prompt': prompt,
          'user_id': session.user.id,
        }),
      );

      if (response.statusCode == 401) {
        final newSession = await supabase.auth.refreshSession();
        if (newSession != null) {
          return sendChatMessage(prompt);
        }
        throw Exception('Authentication failed');
      }

      if (response.statusCode != 200) {
        throw Exception('Failed to send message: ${response.body}');
      }

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }
}

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
