import 'dart:async';
import 'dart:convert';

import 'package:bodido/common_libs.dart';
import 'package:bodido/core/config/env.dart';
import 'package:bodido/data/models/body_simulator_model.dart';
import 'package:bodido/data/models/chat_model.dart';
import 'package:bodido/data/models/tracking_question_model.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as ws_status;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:bodido/core/utils/logger.dart';

class ApiService {
  // DEV
  // static const String _baseUrl = 'http://localhost:8080/api';
  // static const String _wsUrl = 'ws://localhost:8080';
  // PROD
  static String get _baseUrl => Env.apiBaseUrl;
  static String get _wsUrl => Env.wsBaseUrl;

  static final SupabaseClient _supabase = Supabase.instance.client;

  static Future<String> _preferredLanguageCode() async {
    final stored = settingsLogic.currentLocale.value;
    if (stored != null && stored.isNotEmpty) {
      return stored;
    }
    return await findSystemLocale();
  }

  static Future<Map<String, String>> _authHeaders(
    String token, {
    bool includeJson = true,
  }) async {
    final lang = await _preferredLanguageCode();
    final headers = <String, String>{
      'Authorization': 'Bearer $token',
      'Accept-Language': lang,
    };
    if (includeJson) {
      headers['Content-Type'] = 'application/json';
    }
    return headers;
  }

  static Future<Map<String, String>> _languageHeaders() async {
    final lang = await _preferredLanguageCode();
    return {
      'Accept-Language': lang,
    };
  }

  static Stream<String> sendChatMessage(ChatMessageDTO chatMessage) async* {
    final client = http.Client();
    try {
      Future<http.StreamedResponse> _executeSendRequest(String token) async {
        final headers = await _authHeaders(token);
        final request =
            http.Request('POST', Uri.parse('$_baseUrl/generate/chat-reply'))
              ..headers.addAll({
                ...headers,
              })
              ..body = jsonEncode(chatMessage.toJson());
        return client.send(request);
      }

      final initialSession = _supabase.auth.currentSession;
      if (initialSession == null) {
        throw Exception('Not authenticated: No active session.');
      }
      var accessToken = initialSession.accessToken;

      var streamedResponse = await _executeSendRequest(accessToken);

      if (streamedResponse.statusCode == 401) {
        AppLogger.debug('API token expired or invalid, attempting refresh...');
        final authResponse =
            await _supabase.auth.refreshSession(); // AuthResponse

        if (authResponse.session == null ||
            authResponse.session!.accessToken.isEmpty) {
          throw Exception(
              'Authentication failed: Unable to refresh session or new token is invalid.');
        }
        accessToken = authResponse.session!.accessToken; // Use the new token
        AppLogger.debug('Token refreshed. Retrying request with new token...');
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
        AppLogger.error('Error sending message: $errorMessage');
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

      var accessToken = session.accessToken;

      Future<http.Response> executeRequest(String token) async {
        final headers = await _authHeaders(token);
        return http.post(
          Uri.parse('$_baseUrl/generate/memory'),
          headers: headers,
          body: jsonEncode({
            'prompt': prompt,
            'user_id': session.user.id,
          }),
        );
      }

      var response = await executeRequest(accessToken);

      if (response.statusCode == 401) {
        final newSession = await _supabase.auth.refreshSession();
        // The refreshed session is automatically stored by the Supabase client.
        // We can just retry the request.
        if (newSession.session != null) {
          accessToken = newSession.session!.accessToken;
          response = await executeRequest(accessToken); // Retry
        } else {
          throw Exception('Authentication failed');
        }
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
      var accessToken = session.accessToken;

      Future<http.Response> executeRequest(String token) async {
        final localTimestamp = DateTime.now().toIso8601String();
        final uri = Uri.parse(
            '$_baseUrl/initialize/body-simulator?local_timestamp_str=$localTimestamp');

        final headers = await _authHeaders(token);
        return await http.post(
          uri,
          headers: headers,
          body: jsonEncode({}),
        );
      }

      var response = await executeRequest(accessToken);

      if (response.statusCode == 401) {
        AppLogger.debug('API token expired or invalid, attempting refresh...');
        final authResponse = await _supabase.auth.refreshSession();

        if (authResponse.session == null ||
            authResponse.session!.accessToken.isEmpty) {
          throw Exception('Authentication failed: Unable to refresh session.');
        }
        accessToken = authResponse.session!.accessToken;
        AppLogger.debug('Token refreshed. Retrying request with new token...');
        response = await executeRequest(accessToken);
      }

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to initialize body simulator: Status ${response.statusCode} - Body: ${response.body}');
      }

      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      AppLogger.debug(
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

  static Future<Map<String, dynamic>> processSettingsOrMemory(
    ChatMessageDTO chatMessage,
  ) async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('Not authenticated');
      }
      var accessToken = session.accessToken;

      Future<http.Response> executeRequest(String token) async {
        final uri = Uri.parse('$_baseUrl/memory/process');
        final headers = await _authHeaders(token);
        return http.post(
          uri,
          headers: headers,
          body: jsonEncode(chatMessage.toJson()),
        );
      }

      var response = await executeRequest(accessToken);

      if (response.statusCode == 401) {
        final refreshed = await _supabase.auth.refreshSession();
        if (refreshed.session == null ||
            refreshed.session!.accessToken.isEmpty) {
          throw Exception('Authentication failed');
        }
        accessToken = refreshed.session!.accessToken;
        response = await executeRequest(accessToken);
      }

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to process settings or memory: ${response.body}');
      }

      final responseBody = utf8.decode(response.bodyBytes);
      return jsonDecode(responseBody) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Error processing settings or memory: $e');
    }
  }

  // ------------------------------------------------------------
  ///                       Tracking Questions
  // ------------------------------------------------------------
  static Future<List<TrackingQuestion>> createTrackingQuestions({
    String language = 'ko',
    String maxQuestions = '10',
    String optionsPerQuestion = '3',
    String goalFocus = 'general',
    Map<String, dynamic> trackingTargets = const {},
  }) async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('Not authenticated');
      }
      var accessToken = session.accessToken;

      Future<http.Response> executeRequest(String token) async {
        final headers = await _authHeaders(token);
        final uri = Uri.parse('$_baseUrl/create/tracking-questions');
        return http.post(
          uri,
          headers: headers,
          body: jsonEncode({
            'language': language,
            'max_questions': maxQuestions,
            'options_per_question': optionsPerQuestion,
            'goal_focus': goalFocus,
            'tracking_targets': trackingTargets,
          }),
        );
      }

      var response = await executeRequest(accessToken);

      if (response.statusCode == 401) {
        final refreshed = await _supabase.auth.refreshSession();
        if (refreshed.session == null ||
            refreshed.session!.accessToken.isEmpty) {
          throw Exception('Authentication failed');
        }
        accessToken = refreshed.session!.accessToken;
        response = await executeRequest(accessToken);
      }

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to create tracking questions: ${response.statusCode} - ${response.body}',
        );
      }

      final decoded =
          jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      return decoded
          .map((e) => TrackingQuestion.fromJson(
                e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e),
              ))
          .toList();
    } catch (e) {
      throw Exception('Error createTrackingQuestions: $e');
    }
  }

  static Future<Map<String, dynamic>> selectTrackingOption({
    required UserSelectionRequest request,
    bool dryRun = false,
  }) async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('Not authenticated');
      }
      var accessToken = session.accessToken;

      Future<http.Response> executeRequest(String token) async {
        final headers = await _authHeaders(token);
        final uri = Uri.parse('$_baseUrl/select/tracking-option');
        final body = request.toJson();
        if (dryRun) body['dry_run'] = true;
        return http.post(
          uri,
          headers: headers,
          body: jsonEncode(body),
        );
      }

      var response = await executeRequest(accessToken);

      if (response.statusCode == 401) {
        final refreshed = await _supabase.auth.refreshSession();
        if (refreshed.session == null ||
            refreshed.session!.accessToken.isEmpty) {
          throw Exception('Authentication failed');
        }
        accessToken = refreshed.session!.accessToken;
        response = await executeRequest(accessToken);
      }

      if (response.statusCode != 200) {
        throw Exception(
            'Failed select: ${response.statusCode} - ${response.body}');
      }

      return jsonDecode(utf8.decode(response.bodyBytes))
          as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Error selectTrackingOption: $e');
    }
  }

// ------------------------------------------------------------

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
      final lang = await _preferredLanguageCode();
      final wsUri = Uri.parse(
          '$_wsUrl/ws/body-state?token=$jwt&session_id=$sessionId&local_timestamp=$ts&lang=$lang');

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

  static Future<bool> checkServerHealth(
      {Duration timeout = const Duration(seconds: 5)}) async {
    final candidates = <Uri>[];
    try {
      final base = Uri.parse(_baseUrl);
      final origin = Uri(
        scheme: base.scheme,
        host: base.host,
        port: base.hasPort ? base.port : null,
      );
      candidates.add(origin.replace(path: '/')); // GET /
      candidates.add(origin.replace(path: '/health')); // GET /health
      candidates.add(base.replace(
        path: base.path.endsWith('/')
            ? '${base.path}health'
            : '${base.path}/health',
      ));
    } catch (e) {
      debugPrint('Health URL parse error: $e');
    }

    for (final url in candidates) {
      try {
        final headers = await _languageHeaders();
        final res = await http.get(url, headers: headers).timeout(timeout);
        if (res.statusCode == 200) {
          debugPrint('✅ Backend health OK at $url');
          return true;
        } else {
          debugPrint('⚠️ Health check non-200 at $url: ${res.statusCode}');
        }
      } catch (e) {
        debugPrint('❌ Health check failed at $url: $e');
      }
    }
    return false;
  }
}

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
