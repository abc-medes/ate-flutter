import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/views/home/home_view.dart';
import 'presentation/views/home/home_view_model.dart';
import 'data/repositories/user_repository.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel(UserRepository())),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter MVVM',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeView(),
    );
  }
}
