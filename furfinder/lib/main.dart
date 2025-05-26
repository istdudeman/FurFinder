import 'package:flutter/material.dart';
// Import the first page your app should show
import '../pages/role_selection.dart';

// The main entry point of the application.
void main() {
  // Tells Flutter to run the widget defined in MyApp.
  runApp(const MyApp());
}

// This is the root widget of your application.
class MyApp extends StatelessWidget {
  // Constructor for the MyApp widget.
  const MyApp({super.key});

  // The build method describes how to display the widget.
  @override
  Widget build(BuildContext context) {
    // MaterialApp is a convenience widget that wraps a number of
    // widgets that are commonly required for Material Design applications.
    return MaterialApp(
      // The title of your application, used by the device's task switcher.
      title: 'Fur Finder',

      // Hides the "debug" banner in the top-right corner.
      debugShowCheckedModeBanner: false,

      // Defines the overall theme for your application, including the font.
      theme: ThemeData(
        fontFamily: 'Sans', // Sets the default font family.
        // You can add more global theme settings here, like primaryColor, accentColor, etc.
        primarySwatch: Colors.brown, // Example: Set a primary color
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      // Sets the default starting page (widget) for the application.
      // In this case, it's the page where the user selects their role.
      home: const RoleSelectionPage(),
    );
  }
}