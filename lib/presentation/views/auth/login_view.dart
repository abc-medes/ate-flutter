import 'package:ate_project/core/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Provider.of<AuthService>(context, listen: false).login();
            context.go('/'); // Navigate to home after login
          },
          child: Text("Login"),
        ),
      ),
    );
  }
}
