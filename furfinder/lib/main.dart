// furfinder/lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:furfinder/pages/login_page.dart';
import 'package:furfinder/pages/pet_homepage.dart';
import 'package:furfinder/models/user_role.dart';

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
      // Use StreamBuilder to listen for authentication state changes
      home: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while the initial authentication state is being determined
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          // Extract session and user from AuthState
          final Session? session = snapshot.data?.session;
          final User? user = session?.user;

          if (user != null) {
            // If a user is logged in, fetch their role from the 'users' table
            return FutureBuilder<Map<String, dynamic>>(
              future: _fetchUserRoleFromSupabase(user.id),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(body: Center(child: CircularProgressIndicator()));
                } else if (roleSnapshot.hasData && roleSnapshot.data?['role'] != null) {
                  // Navigate to PetHomePage with the determined user role
                  final String roleString = roleSnapshot.data!['role'];
                  final UserRole userRole = roleString == 'admin' ? UserRole.admin : UserRole.customer;
                  return PetHomePage(role: userRole);
                } else {
                  // Fallback: If user role cannot be fetched, sign them out and show login page
                  debugPrint('Error: Could not fetch user role. Signing out and navigating to LoginPage.');
                  Supabase.instance.client.auth.signOut(); // Sign out the current session
                  return const LoginPage();
                }
              },
            );
          } else {
            // If no user is logged in (session is null), show the LoginPage
            return const LoginPage();
          }
        },
      ),
    );
  }

  // Helper function to fetch user role from Supabase 'users' table
  Future<Map<String, dynamic>> _fetchUserRoleFromSupabase(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('users')
          .select('role')
          .eq('id', userId)
          .single(); // Assuming 'id' is a unique primary key for users
      return response as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error fetching user role for auto-login: $e');
      return {}; // Return an empty map on error to trigger the fallback in StreamBuilder
    }
  }
}