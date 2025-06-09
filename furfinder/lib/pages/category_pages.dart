import 'package:flutter/material.dart';
import '../models/user_role.dart';
import '../widgets/history_entry.dart';
import '../widgets/profile_card.dart';
import 'package:intl/intl.dart';
import 'transactions_page.dart'; // Import the transaction page

class CategoryPage extends StatefulWidget {
  final String title;
  final String emoji;
  final Color bgColor;
  final UserRole role;
  final String petID;
  final String serviceID; // Define the new parameter

  const CategoryPage({
    super.key,
    required this.title,
    required this.emoji,
    required this.bgColor,
    required this.role,
    required this.petID,
    required this.serviceID, // Add it to the constructor
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late List<Map<String, String>> history;

  @override
  void initState() {
    super.initState();
    final allHistory = [
      {"service": "Bathing", "date": "2 Januari 2024"},
      {"service": "Bathing", "date": "5 Januari 2024"},
      {"service": "Nail Trimmer", "date": "7 Januari 2024"},
      {"service": "Haircut", "date": "10 Januari 2024"},
      {"service": "Bathing", "date": "15 Januari 2024"},
      {"service": "Haircut", "date": "20 Januari 2024"},
    ];
    history =
        allHistory
            .where((h) => h["service"] == widget.title.replaceAll('\n', ' '))
            .toList();
  }

  bool get isCustomer => widget.role == UserRole.customer;

  // This function now navigates to the transaction page
  void _addNewOrder() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => TransactionPage(
              petID: widget.petID,
              serviceID: widget.serviceID, // Pass the ID here
            ),
      ),
    );
  }

  // The rest of your build method and other functions remain the same...
  // Just ensure the onPressed for the "New Order" button calls _addNewOrder
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        // ... (your existing UI structure)
      ),
      bottomNavigationBar:
          isCustomer
              ? Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.bgColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  onPressed:
                      _addNewOrder, // This now navigates to the transaction page
                  child: const Text(
                    "New Order",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              )
              : null,
    );
  }
}
