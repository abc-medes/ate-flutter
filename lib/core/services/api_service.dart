import 'dart:convert';
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  final String baseUrl = 'http://localhost:8080/api';
  final SupabaseClient supabase = Supabase.instance.client;

  Stream<String> sendChatMessage(String prompt) async* {
    final client = http.Client();
    try {
      Future<http.StreamedResponse> _executeSendRequest(String token) async {
        final request =
            http.Request('POST', Uri.parse('$baseUrl/generate/health'))
              ..headers.addAll({
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              })
              ..body = jsonEncode({
                'prompt': prompt,
                'user_id': supabase.auth.currentUser!.id,
              });
        return client.send(request);
      }

      final initialSession = supabase.auth.currentSession;
      if (initialSession == null) {
        throw Exception('Not authenticated: No active session.');
      }
      String accessToken = initialSession.accessToken;

      var streamedResponse = await _executeSendRequest(accessToken);

      if (streamedResponse.statusCode == 401) {
        print('API token expired or invalid, attempting refresh...');
        final authResponse =
            await supabase.auth.refreshSession(); // AuthResponse

        if (authResponse.session == null ||
            authResponse.session!.accessToken.isEmpty) {
          throw Exception(
              'Authentication failed: Unable to refresh session or new token is invalid.');
        }
        accessToken = authResponse.session!.accessToken; // Use the new token
        print('Token refreshed. Retrying request with new token...');
        streamedResponse = await _executeSendRequest(accessToken); // Retry
      }

      if (streamedResponse.statusCode != 200) {
        final errorBody = await streamedResponse.stream.bytesToString();
        throw Exception(
            'Failed to send message: Status ${streamedResponse.statusCode} ${streamedResponse.reasonPhrase} - Body: $errorBody');
      }

      await for (final chunk
          in streamedResponse.stream.transform(utf8.decoder)) {
        yield chunk;
      }
    } catch (e) {
      // Clean up the exception message to avoid "Exception: Exception: ..."
      if (e is Exception) {
        final errorMessage = e.toString();
        throw Exception(
            'Error sending message: ${errorMessage.startsWith("Exception: ") ? errorMessage.substring("Exception: ".length) : errorMessage}');
      } else {
        throw Exception('Error sending message: $e');
      }
    } finally {
      client.close();
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
          return memorizeChat(prompt);
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

  Future<Map<String, dynamic>> createChatRoom() async {
    try {
      final session = supabase.auth.currentSession;

      if (session == null) {
        throw Exception('Not authenticated');
      }

      final accessToken = session.accessToken;

      final response = await http.post(
        Uri.parse('$baseUrl/create-room'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 401) {
        final newSession = await supabase.auth.refreshSession();
        if (newSession != null) {
          return createChatRoom();
        }
        throw Exception('Authentication failed');
      }

      if (response.statusCode != 200) {
        throw Exception('Failed to create chat room: ${response.body}');
      }

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Error creating chat room: $e');
    }
  }
}

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
