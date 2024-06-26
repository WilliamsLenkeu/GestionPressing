import 'package:flutter/material.dart';

import '../constants.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Page de Connexion',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Constants.primaryColor,
        centerTitle: true,
      ),
    );
  }
}
