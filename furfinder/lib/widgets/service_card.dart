import 'package:flutter/material.dart';
import '../pages/category_pages.dart';
import '../models/user_role.dart'; 

class ServiceCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final UserRole role;
  final String petID;
  final String serviceID; // Define the new parameter

  const ServiceCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.role,
    required this.petID,
    required this.serviceID, // Add it to the constructor
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                // Pass the serviceID to the CategoryPage
                (_) => CategoryPage(
                  title: title, 
                  emoji: '🐾', 
                  bgColor: color, 
                  role: role, 
                  petID: petID,
                  serviceID: serviceID, // Pass it here
                ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}