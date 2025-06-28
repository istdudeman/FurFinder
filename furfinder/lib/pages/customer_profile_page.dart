// furfinder/lib/pages/customer_profile_page.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:furfinder/api/pet_api.dart'; // Reusing existing pet_api for pet profile
import 'package:furfinder/api/transaction_api.dart'; // Import transaction_api for payment functions
import 'package:intl/intl.dart'; // For date formatting

class CustomerProfilePage extends StatefulWidget {
  const CustomerProfilePage({super.key});

  @override
  State<CustomerProfilePage> createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage> {
  Map<String, dynamic>? _customerData;
  List<Map<String, dynamic>> _petsData = []; // Changed to a list
  List<Map<String, dynamic>> _pendingBookings = []; // New list for pending bookings
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
    _fetchPendingBookings(); // Fetch pending bookings on init
  }

  Future<void> _fetchProfileData() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        setState(() {
          _errorMessage = 'User not logged in.';
          _isLoading = false;
        });
        return;
      }

      // Fetch customer biodata
      final customerResponse = await supabase
          .from('users')
          .select('name, email, phone_number, address')
          .eq('id', user.id)
          .maybeSingle();

      if (customerResponse != null) {
        _customerData = customerResponse;
      } else {
        _errorMessage = 'Customer data not found.';
      }

      // Fetch ALL pet biodata for the user
      final List<Map<String, dynamic>> petResponses = await supabase
          .from('pets')
          .select('animal_id, name, breed, age')
          .eq('user_id', user.id) as List<Map<String, dynamic>>; // Cast to List<Map<String, dynamic>>

      _petsData = petResponses; // Assign the list of pets

      if (_petsData.isEmpty) {
        _errorMessage += '\nNo pet registered yet.';
      }

    } catch (e) {
      _errorMessage = 'Error fetching data: $e';
      debugPrint('Error in _fetchProfileData (CustomerProfilePage): $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchPendingBookings() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) return;

      // Fetch bookings with 'pending_payment' status for the current user
      final response = await supabase
          .from('bookings')
          .select('booking_id, start_date, end_date, total_price, status, pets(name)') // Join with pets table to get pet name
          .eq('user_id', user.id)
          .eq('status', 'pending_payment'); // Filter for pending payments

      setState(() {
        _pendingBookings = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint('Error fetching pending bookings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching pending payments: $e')),
        );
      }
    }
  }

  // Function to handle payment confirmation
  Future<void> _handleConfirmPayment(String bookingId) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to confirm payment.')),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator during confirmation
    });

    try {
      // Call the API function to confirm payment
      final success = await confirmPaymentMade(bookingId, user.id); //

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment confirmation sent! Admin will verify.')),
          );
          _fetchPendingBookings(); // Refresh the list to remove confirmed booking
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to send payment confirmation. Please try again.')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error confirming payment in UI: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color(0xFFB9C57D),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty && _customerData == null && _petsData.isEmpty && _pendingBookings.isEmpty
              ? Center(child: Text(_errorMessage, textAlign: TextAlign.center))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer Biodata Section
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Customer Biodata',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown),
                              ),
                              const Divider(),
                              _buildProfileRow('Name', _customerData?['name'] ?? 'N/A'),
                              _buildProfileRow('Email', _customerData?['email'] ?? 'N/A'),
                              _buildProfileRow('Phone', _customerData?['phone_number'] ?? 'N/A'),
                              _buildProfileRow('Address', _customerData?['address'] ?? 'N/A'),
                            ],
                          ),
                        ),
                      ),

                      // Pet Biodata Section
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Pet Biodata',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown),
                              ),
                              const Divider(),
                              if (_petsData.isNotEmpty)
                                ..._petsData.map((pet) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildProfileRow('Pet Name', pet['name'] ?? 'N/A'),
                                      _buildProfileRow('Breed', pet['breed'] ?? 'N/A'),
                                      _buildProfileRow('Age', (pet['age'] ?? 'N/A').toString()),
                                      const SizedBox(height: 10), // Add spacing between pets
                                      if (_petsData.indexOf(pet) < _petsData.length - 1)
                                        const Divider(), // Add divider between multiple pets
                                    ],
                                  );
                                }).toList()
                              else
                                const Text('No pet registered yet.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                      
                      // Manual Payment Instructions Section
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Manual Payment Instructions',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown),
                              ),
                              const Divider(),
                              _buildProfileRow('Bank Name', 'Example Bank'),
                              _buildProfileRow('Account Name', 'FurFinder Pet Services'),
                              _buildProfileRow('Account Number', '1234 5678 9012 3456'),
                              const SizedBox(height: 10),
                              const Text(
                                'Please make a bank transfer to the account above. Once transferred, select the booking below and click "Confirm Payment".',
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              const SizedBox(height: 20),

                              // List of pending payments
                              if (_pendingBookings.isNotEmpty) ...[
                                const Text(
                                  'Pending Payments:',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                ..._pendingBookings.map((booking) {
                                  return Card(
                                    margin: const EdgeInsets.symmetric(vertical: 5),
                                    child: ListTile(
                                      title: Text('Booking for ${booking['pets']['name'] ?? 'Unknown Pet'}'),
                                      subtitle: Text(
                                          'Total: \$${(booking['total_price'] as num).toStringAsFixed(2)} '
                                          '(${DateFormat('yyyy-MM-dd').format(DateTime.parse(booking['start_date']))} - '
                                          '${DateFormat('yyyy-MM-dd').format(DateTime.parse(booking['end_date']))})'),
                                      trailing: ElevatedButton(
                                        onPressed: _isLoading ? null : () => _handleConfirmPayment(booking['booking_id']),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.brown[800],
                                        ),
                                        child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Confirm Payment', style: TextStyle(color: Colors.white)),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ] else if (!_isLoading) ...[
                                const Text('No pending payments.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                              ],
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}