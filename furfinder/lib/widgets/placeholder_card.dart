import 'package:flutter/material.dart';

class PlaceholderCard extends StatelessWidget {
  final String emoji;

  const PlaceholderCard({super.key, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          "$emoji\nComing Soon",
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}