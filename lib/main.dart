import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:talka/screens/auth/login_screen.dart';
import 'package:talka/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const TalkaApp());
}

class TalkaApp extends StatelessWidget {
  const TalkaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Talka',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
