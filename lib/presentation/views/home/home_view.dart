import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_view_model.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: viewModel.isLoading
            ? CircularProgressIndicator()
            : viewModel.user != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("User: ${viewModel.user!.name}"),
                      Text("Email: ${viewModel.user!.email}"),
                    ],
                  )
                : Text("No user loaded"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => viewModel.loadUser("123"),
        child: Icon(Icons.refresh),
      ),
    );
  }
}
