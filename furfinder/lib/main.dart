// furfinder/lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:furfinder/pages/customer_login_page.dart';
import 'package:furfinder/pages/login_page.dart'; // Make sure this import exists and is correct

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://oipfczyfaywounyyrzbm.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9pcGZjenlmYXl3b3VueXlyemJtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA5NDE2MjEsImV4cCI6MjA2NjUxNzYyMX0.tirrekFk3Z15NrIMBHyCcA2kaTml_8SXVWconHrDyKo',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fur Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Sans',
        primarySwatch: Colors.brown,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Change this line:
      home: const LoginPage(), // Now starting with the Login Page which has both options
    );
  }
}