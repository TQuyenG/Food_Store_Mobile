import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/trang_chu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Store',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: TrangChu(),
    );
  }
}