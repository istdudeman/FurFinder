// furfinder/lib/pages/category_pages.dart
import 'package:flutter/material.dart';
import '../models/user_role.dart';
import '../widgets/history_entry.dart';
import '../widgets/profile_card.dart';
import 'package:intl/intl.dart';
import 'transactions_page.dart'; // Import the transaction page
import '../api/transaction_api.dart' as transaction_api; // Import transaction_api

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
  late List<Map<String, String>> history; // Kept for customer history
  List<Map<String, dynamic>> _adminBookings = []; // New list for admin bookings
  bool _isLoadingBookings = true; // New loading state for admin bookings

  @override
  void initState() {
    super.initState();
    final allHistory = [
      {"service": "Bathing", "date": "2 Januari 2024"},
      {"service": "Bathing", "date": "5 Januari 2024"},
      {"service": "Nail Trimmer", "date": "7 Januari 2024"},
      {"service": "Hair cut", "date": "10 Januari 2024"},
      {"service": "Bathing", "date": "15 Januari 2024"},
      {"service": "Hair cut", "date": "20 Januari 2024"},
    ];
    history =
        allHistory
            .where((h) => h["service"] == widget.title.replaceAll('\n', ' '))
            .toList();

    // Fetch bookings for admin if role is admin
    if (widget.role == UserRole.admin) {
      _fetchAdminBookings();
    }
  }

  Future<void> _fetchAdminBookings() async {
    setState(() {
      _isLoadingBookings = true;
    });
    try {
      final bookings = await transaction_api.fetchBookingsByServiceId(widget.serviceID);
      if (mounted) {
        setState(() {
          _adminBookings = bookings;
        });
      }
    } catch (e) {
      debugPrint('Error fetching admin bookings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load bookings for admin: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingBookings = false;
        });
      }
    }
  }

  Future<void> _confirmBooking(String bookingId) async {
    try {
      await transaction_api.confirmBookingDone(bookingId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Booking confirmed as done ✅")),
        );
        _fetchAdminBookings(); // Refresh bookings
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error confirming booking: $e")),
        );
      }
    }
  }

  bool get isCustomer => widget.role == UserRole.customer;
  bool get isAdmin => widget.role == UserRole.admin; // Helper for admin role

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: widget.bgColor,
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(80),
              ),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white24,
                          child: Text(
                            widget.emoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.title.replaceAll('\n', ' '),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pet Profile Card (only for customer)
                        if (isCustomer) ...[
                          ProfileCard(petID: widget.petID),
                          const SizedBox(height: 30),
                        ],

                        // Display History for Customer, or Bookings for Admin
                        Text(
                          isAdmin ? "Bookings for ${widget.title.replaceAll('\n', ' ')}" : "History",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Conditional display based on role
                        if (isAdmin)
                          _isLoadingBookings
                              ? const Center(child: CircularProgressIndicator())
                              : _adminBookings.isEmpty
                                  ? const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(20.0),
                                        child: Text(
                                          "No bookings found for this service.",
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                    )
                                  : Column(
                                      children: _adminBookings.map((booking) {
                                        final petName = booking['pets']?['name'] ?? 'Unknown Pet';
                                        final cageNumber = booking['cage']?['cage_number']?.toString() ?? 'N/A';
                                        final startDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(booking['start_date']));
                                        final endDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(booking['end_date']));
                                        final status = booking['status'] ?? 'N/A';
                                        final totalPrice = (booking['total_price'] as num).toStringAsFixed(2);
                                        final bookingId = booking['booking_id'].toString();
                                        final service_status = booking['service_status'] ?? 'N/A';

                                        return Card(
                                          margin: const EdgeInsets.symmetric(vertical: 5),
                                          child: ListTile(
                                            title: Text('$petName - Cage $cageNumber'),
                                            subtitle: Text(
                                              'Dates: $startDate to $endDate\nStatus: $status\nPrice: \$$totalPrice\nService Status : $service_status',
                                            ),
                                            isThreeLine: true,
                                            trailing: service_status != 'completed'
                                                ? ElevatedButton(
                                                    onPressed: () => _confirmBooking(bookingId),
                                                    child: const Text("Confirm Done"),
                                                  )
                                                : const Icon(Icons.check_circle, color: Colors.green),
                                          ),
                                        );
                                      }).toList(),
                                    )
                        else // isCustomer
                          if (history.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text(
                                  "No history found for this service.",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            )
                          else
                            Column(
                              children: history.map((entry) {
                                return HistoryEntry(
                                  service: entry["service"]!,
                                  date: entry["date"]!,
                                );
                              }).toList(),
                            ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
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
              : null, // No "New Order" button for admin
    );
  }
}
