import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gestwash/ui/onboarding_screen.dart';
import 'firebase_options.dart';

void main(){
  Firebase.initializeApp(
    options: DefaultFire
  )
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Onboarding Screen',
      home: OnboardingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
