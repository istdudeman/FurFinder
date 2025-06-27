// furfinder/lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/login_page.dart'; // Import the new login page

void main() async {
  // Wajib untuk inisialisasi sebelum runApp
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://oipfczyfaywounyyrzbm.supabase.co', // Ganti dengan URL dari Supabase project kamu
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9pcGZjenlmYXl3b3VueXlyemJtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA5NDE2MjEsImV4cCI6MjA2NjUxNzYyMX0.tirrekFk3Z15NrIMBHyCcA2kaTml_8SXVWconHrDyKo', // Ganti dengan anon key dari Supabase
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
      home: const LoginPage(), // Start with the LoginPage
    );
  }
}