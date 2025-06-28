// furfinder/lib/pages/customer_profile_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:furfinder/api/pet_api.dart'; // Reusing existing pet_api for pet profile

class CustomerProfilePage extends StatefulWidget {
  const CustomerProfilePage({super.key});

  @override
  State<CustomerProfilePage> createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage> {
  Map<String, dynamic>? _customerData;
  Map<String, dynamic>? _petData;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
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
      // Assuming 'users' table has columns: name, email, phone_number, address, role
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

      // Fetch pet biodata
      // Using .limit(1) to get only one pet's ID and details, as the current UI displays a single pet profile.
      final petResponse = await supabase
          .from('pets')
          .select('animal_id, name, breed, age')
          .eq('user_id', user.id)
          .limit(1) // Ensure only one pet is fetched, even if the user has multiple
          .maybeSingle();

      if (petResponse != null) {
        _petData = petResponse;
      } else {
        _errorMessage += '\nPet data not found or no pet registered.';
      }

    } catch (e) {
      _errorMessage = 'Error fetching data: $e';
      debugPrint('Error in _fetchProfileData (CustomerProfilePage): $e');
    } finally {
      if (mounted) { // Ensure widget is still mounted before calling setState
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
          : _errorMessage.isNotEmpty
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
                              _petData != null
                                  ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildProfileRow('Pet Name', _petData?['name'] ?? 'N/A'),
                                        _buildProfileRow('Breed', _petData?['breed'] ?? 'N/A'),
                                        _buildProfileRow('Age', (_petData?['age'] ?? 'N/A').toString()),
                                      ],
                                    )
                                  : const Text('No pet registered yet.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20), // Spacer

                      // Payment Options Section
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
                                'Please make a bank transfer to the account above. Once transferred, click the "Confirm Payment" button.',
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              const SizedBox(height: 20),
                              Center(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    // In a real application, this would trigger a notification
                                    // to the admin for manual verification.
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Payment confirmation sent! Admin will verify.')),
                                    );
                                  },
                                  icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                                  label: const Text(
                                    'Confirm Payment',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.brown[800],
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
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