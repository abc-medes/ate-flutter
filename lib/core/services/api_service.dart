import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:regene/common_libs.dart';
import 'package:regene/data/models/body_simulator_model.dart';
import 'package:regene/data/models/chat_model.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as ws_status;
import 'package:web_socket_channel/web_socket_channel.dart';

class ApiService {
  static const String _baseUrl = 'http://localhost:8080/api';
  static const String _wsUrl = 'ws://localhost:8080';
  static final SupabaseClient _supabase = Supabase.instance.client;

  static Stream<String> sendChatMessage(ChatMessageDTO chatMessage) async* {
    final client = http.Client();
    try {
      Future<http.StreamedResponse> _executeSendRequest(String token) async {
        final request =
            http.Request('POST', Uri.parse('$_baseUrl/generate/chat-reply'))
              ..headers.addAll({
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              })
              ..body = jsonEncode(chatMessage.toJson());
        return client.send(request);
      }

      final initialSession = _supabase.auth.currentSession;
      if (initialSession == null) {
        throw Exception('Not authenticated: No active session.');
      }
      String accessToken = initialSession.accessToken;

      var streamedResponse = await _executeSendRequest(accessToken);

      if (streamedResponse.statusCode == 401) {
        print('API token expired or invalid, attempting refresh...');
        final authResponse =
            await _supabase.auth.refreshSession(); // AuthResponse

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
        print('Error sending message: $errorMessage');
        throw Exception(
            'Error sending message: ${errorMessage.startsWith("Exception: ") ? errorMessage.substring("Exception: ".length) : errorMessage}');
      } else {
        throw Exception('Error sending message: $e');
      }
    } finally {
      client.close();
    }
  }

  static Future<Map<String, dynamic>> memorizeChat(String prompt) async {
    try {
      final session = _supabase.auth.currentSession;

      if (session == null) {
        throw Exception('Not authenticated');
      }

      final accessToken = session.accessToken;

      final response = await http.post(
        Uri.parse('$_baseUrl/generate/memory'),
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
        final newSession = await _supabase.auth.refreshSession();
        // The refreshed session is automatically stored by the Supabase client.
        // We can just retry the request.
        if (newSession.session != null) {
          return memorizeChat(prompt); // Retry with the new session
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

  static Future<void> initializeBodySimulatorState() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('Not authenticated: No active session.');
      }
      String accessToken = session.accessToken;

      Future<http.Response> executeRequest(String token) async {
        final localTimestamp = DateTime.now().toIso8601String();
        final uri = Uri.parse(
            '$_baseUrl/initialize/body-simulator?local_timestamp_str=$localTimestamp');

        return await http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({}),
        );
      }

      var response = await executeRequest(accessToken);

      if (response.statusCode == 401) {
        print('API token expired or invalid, attempting refresh...');
        final authResponse = await _supabase.auth.refreshSession();

        if (authResponse.session == null ||
            authResponse.session!.accessToken.isEmpty) {
          throw Exception('Authentication failed: Unable to refresh session.');
        }
        accessToken = authResponse.session!.accessToken;
        print('Token refreshed. Retrying request with new token...');
        response = await executeRequest(accessToken);
      }

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to initialize body simulator: Status ${response.statusCode} - Body: ${response.body}');
      }

      final responseBody = jsonDecode(response.body);
      print(
          'Body simulator initialized successfully: ${responseBody['message']}');
    } catch (e) {
      if (e is Exception) {
        final errorMessage = e.toString();
        throw Exception(
            'Error initializing body simulator: ${errorMessage.startsWith("Exception: ") ? errorMessage.substring("Exception: ".length) : errorMessage}');
      } else {
        throw Exception('Error initializing body simulator: $e');
      }
    }
  }

  static Stream<BodySimulatorStateSnapshotDTO> bodyStateStream({
    required String sessionId,
    Duration reconnectDelay = const Duration(seconds: 2),
  }) {
    final controller = StreamController<BodySimulatorStateSnapshotDTO>();
    WebSocketChannel? channel;
    bool hasReceivedData = false;

    Future<void> connect() async {
      if (controller.isClosed) return;

      final session = _supabase.auth.currentSession;
      if (session == null) {
        if (!controller.isClosed) {
          controller.addError(Exception('Not authenticated'));
          await controller.close();
        }
        return;
      }

      final jwt = session.accessToken;
      final ts = DateTime.now().toIso8601String();
      final wsUri = Uri.parse(
          '$_wsUrl/ws/body-state?token=$jwt&session_id=$sessionId&local_timestamp=$ts');

      debugPrint('🌐 Attempting WebSocket connection to: $wsUri');

      try {
        channel = IOWebSocketChannel.connect(wsUri);
        debugPrint('🌐 WebSocket connection established');

        channel!.stream.listen(
          (message) {
            if (controller.isClosed) return;
            try {
              final data = jsonDecode(message);
              debugPrint(
                  '🌐 Received message: ${message.toString().substring(0, 100)}...');
              if (data is Map<String, dynamic>) {
                hasReceivedData = true;
                controller.add(BodySimulatorStateSnapshotDTO.fromJson(data));
              }
            } catch (_) {
              debugPrint('🌐 Parse error: $_');
            }
          },
          onError: (error) {
            debugPrint('🌐 WebSocket error: $error');
            if (!controller.isClosed) controller.addError(error);
          },
          cancelOnError: true,
          onDone: () async {
            debugPrint('🌐 WebSocket connection done/closed');
            if (controller.isClosed) return;

            final code = channel?.closeCode;
            debugPrint('🌐 Close code: $code');

            // If we received data and connection closed normally, this is success
            if (hasReceivedData &&
                (code == ws_status.normalClosure || code == 1000)) {
              debugPrint(
                  '🌐 Connection closed after successful data transmission');
              return;
            }

            // Only reconnect for unexpected closures
            if (code == 4001) {
              debugPrint(
                  '🌐 Authentication error, attempting to refresh session');
              final refreshed = await _supabase.auth.refreshSession();
              if (refreshed.session != null) {
                await Future.delayed(reconnectDelay);
                connect();
                return;
              }
            }

            debugPrint('🌐 Unexpected connection closure with code: $code');
          },
        );
      } catch (e) {
        debugPrint('🌐 Connection error: $e');
        if (!controller.isClosed) {
          controller.addError(e);
        }
      }
    }

    connect();

    controller.onCancel = () async {
      debugPrint('🌐 Stream cancelled, closing WebSocket');
      await controller.close();
      await channel?.sink.close(ws_status.normalClosure);
      channel = null;
    };

    return controller.stream;
  }
}

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
