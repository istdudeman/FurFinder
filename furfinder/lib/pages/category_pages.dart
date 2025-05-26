import 'package:flutter/material.dart';
import '../models/user_role.dart'; 
import '../widgets/history_entry.dart';
import '../widgets/profile_card.dart';
import 'package:intl/intl.dart'; // <-- Import for date formatting

class CategoryPage extends StatefulWidget {
  final String title;
  final String emoji;
  final Color bgColor;
  final UserRole role; // <-- Added role

  const CategoryPage({
    super.key,
    required this.title,
    required this.emoji,
    required this.bgColor,
    required this.role, // <-- Added to constructor
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  // Use a List in the state to allow modifications
  late List<Map<String, String>> history;

  @override
  void initState() {
    super.initState();
    // Initialize history (you might fetch this later)
    // This example filters based on title - adjust if needed
    final allHistory = [
      {"service": "Bathing", "date": "2 Januari 2024"},
      {"service": "Bathing", "date": "5 Januari 2024"},
      {"service": "Nail Trimmer", "date": "7 Januari 2024"},
      {"service": "Haircut", "date": "10 Januari 2024"},
      {"service": "Bathing", "date": "15 Januari 2024"},
      {"service": "Haircut", "date": "20 Januari 2024"},
    ];
    // Filter history based on the current page's title
    history = allHistory
        .where((h) => h["service"] == widget.title.replaceAll('\n', ' '))
        .toList();
  }

  // Getter to easily check if the user is a customer
  bool get isCustomer => widget.role == UserRole.customer;

  // Function to show the success dialog
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: true, // Allow dismissing by tapping outside
      barrierColor: Colors.black.withOpacity(0.6), // Dim the background
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent, // Make dialog background transparent
        elevation: 0, // No shadow
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          decoration: BoxDecoration(
            color: widget.bgColor.withOpacity(0.95), // Use page background color
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.7), width: 1.5)
          ),
          child: const Text(
            "SUCCESS",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );

     // Close the dialog automatically after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      // Check if the dialog is still open before trying to pop
      if (Navigator.of(context, rootNavigator: true).canPop()) {
         Navigator.of(context, rootNavigator: true).pop();
      }
    });
  }

  // Function to handle adding a new order
  void _addNewOrder() {
    // 1. Get current date and format it (using Indonesian locale)
    final now = DateTime.now();
    final formatter = DateFormat('d MMMM yyyy', 'id_ID');
    final formattedDate = formatter.format(now);

    // 2. Update the state: Add new order and rebuild UI
    setState(() {
      history.insert(0, {
        "service": widget.title.replaceAll('\n', ' '),
        "date": formattedDate,
      });
    });

    // 3. Show Success Feedback
    _showSuccessDialog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            height: 280,
            decoration: BoxDecoration(
              color: widget.bgColor,
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(80),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0), // Adjust padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button at the top
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    padding: EdgeInsets.zero, // Remove default padding
                    alignment: Alignment.centerLeft, // Align left
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      // Consider adding color: Colors.black if not visible
                    ),
                  ),
                  const SizedBox(height: 20),
                  const ProfileCard(), // Your existing Profile Card
                  const SizedBox(height: 30),
                  const Text(
                    "History",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Use Expanded to make the list scrollable within the Column
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero, // Remove top/bottom padding
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final entry = history[index];
                        return HistoryEntry(
                            service: entry["service"]!, date: entry["date"]!);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // Only show the button if the user is a customer
      bottomNavigationBar: isCustomer
          ? Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 25), // Add padding
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.bgColor, // Use the page color
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5, // Add a little shadow
                ),
                onPressed: _addNewOrder, // Call the add order function
                child: const Text(
                  "New Order",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            )
          : null, // If not customer, show nothing
    );
  }
}