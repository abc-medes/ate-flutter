import 'package:flutter/material.dart';
import 'package:ate_project/core/widgets/loading_screen.dart';

class LoadingView extends StatelessWidget {
  final String? message;

  const LoadingView({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingScreen(
        message: message,
        showLogo: true,
      ),
    );
  }
}
