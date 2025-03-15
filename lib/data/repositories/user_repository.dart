import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class UserRepository {
  Future<User> fetchUser(String userId) async {
    final response =
        await http.get(Uri.parse('https://api.example.com/user/$userId'));

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user');
    }
  }
}
