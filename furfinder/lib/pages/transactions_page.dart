import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class TransactionPage extends StatefulWidget {
  final String petID;
  final String? serviceID; // Make serviceID optional

  const TransactionPage({super.key, required this.petID, this.serviceID}); // Update constructor

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  double _totalPrice = 0.0;
  String? _selectedCageId;
  String? _selectedServiceId;

  List<dynamic> _cages = [];
  List<dynamic> _services = [];
  Map<String, dynamic>? _petDetails;

  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  bool _isLoading = true;

  // IMPORTANT: Replace with your actual ngrok URL
  final String ngrokUrl = "https://c34b-182-253-50-98.ngrok-free.app";

  @override
  void initState() {
    super.initState();
    _selectedServiceId = widget.serviceID; // Handle optional serviceID
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    try {
      await Future.wait([
        _fetchPetDetails(),
        _fetchServices(),
        _fetchCages(),
      ]);
      _calculatePrice();
    } catch (e) {
      print("Error fetching initial data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading data: $e")),
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

  Future<void> _fetchPetDetails() async {
    final response = await http.get(Uri.parse('$ngrokUrl/api/pets/${widget.petID}'));
    print("Pet ID yang dikirim: ${widget.petID}");
    if (response.statusCode == 200) {
      _petDetails = json.decode(response.body);
    } else {
      throw Exception('Failed to load pet details');
    }
  }

  Future<void> _fetchServices() async {
    final response = await http.get(Uri.parse('$ngrokUrl/api/services/list'));
    if (response.statusCode == 200) {
      _services = json.decode(response.body);
    } else {
      throw Exception('Failed to load services');
    }
  }

  Future<void> _fetchCages() async {
    final response = await http.get(Uri.parse('$ngrokUrl/api/cage/list'));
    print("Cages JSON: ${response.body}");
    if (response.statusCode == 200) {
      _cages = json.decode(response.body);
    } else {
      throw Exception('Failed to load cages');
    }
  }

  void _calculatePrice() {
    if (_startDate == null || _endDate == null || _selectedCageId == null || _selectedServiceId == null) {
      return;
    }

    final days = _endDate!.difference(_startDate!).inDays;
    print("Days difference: $days");
    if (days > 0) {
      final cage = _cages.firstWhere((c) => c['cage_id'] == _selectedCageId);
      final service = _services.firstWhere((s) => s['services_id'] == _selectedServiceId);
      final cagePricePerDay = (cage['price_per_day'] as num).toDouble();
      final servicePrice = (service['price'] as num).toDouble();

      print("Cage Price Per Day: $cagePricePerDay");
      print("Service Price: $servicePrice");
      print("Days: $days");


      setState(() {
        _totalPrice = (days * cagePricePerDay) + servicePrice;
      });
    } else {
       setState(() {
        _totalPrice = 0;
      });
    }
  }
  
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          _startDateController.text = DateFormat('yyyy-MM-dd').format(picked);
          if(_endDate != null && _endDate!.isBefore(_startDate!)){
            _endDate = null;
            _endDateController.text = "";
          }
        } else {
          _endDate = picked;
          _endDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        }
        _calculatePrice();
      });
    }
  }

  Future<void> _confirmBooking() async {
    if (_startDate == null || _endDate == null || _selectedCageId == null || _selectedServiceId == null || _totalPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields and ensure the dates are correct.")),
      );
      return;
    }

    final url = Uri.parse('$ngrokUrl/api/booking/addbookings');
    final uuid = Uuid();
    final bookingId = uuid.v4(); // generate random UUID

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'booking_id': bookingId,
        'user_id': 'e993c4f1-b374-4cf9-af7a-c1a683f2f29d', // Replace with actual user ID
        'start_date': DateFormat('yyyy-MM-dd').format(_startDate!),
        'end_date': DateFormat('yyyy-MM-dd').format(_endDate!),
        'status': 'confirmed',
        'total_price': _totalPrice,
        'animal_id': widget.petID,
        'cage_id': _selectedCageId,
        'services_id': _selectedServiceId,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking successful!")),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Booking failed: ${response.body}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Booking'),
        backgroundColor: const Color(0xFFB9C57D),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_petDetails != null) ...[
                    Text("Pet: ${_petDetails!['name']}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                  ],

                  DropdownButtonFormField<String>(
                    value: _selectedServiceId,
                    items: _services.map<DropdownMenuItem<String>>((service) {
                      return DropdownMenuItem<String>(
                        value: service['services_id'],
                        child: Text(service['services_name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedServiceId = value;
                        _calculatePrice();
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Service',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  DropdownButtonFormField<String>(
                    value: _selectedCageId,
                    items: _cages.map<DropdownMenuItem<String>>((cage) {
                      return DropdownMenuItem<String>(
                        value: cage['cage_id'],
                        child: Text("Cage ${cage['cage_number']} (${cage['animal_type']})"),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCageId = value;
                        _calculatePrice();
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Cage',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _startDateController,
                          decoration: const InputDecoration(
                            labelText: 'Start Date',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          readOnly: true,
                          onTap: () => _selectDate(context, true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _endDateController,
                          decoration: const InputDecoration(
                            labelText: 'End Date',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          readOnly: true,
                          onTap: () => _selectDate(context, false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Center(
                    child: Text(
                      'Total Price: \$${_totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ),
                  const SizedBox(height: 30),

                  Center(
                    child: ElevatedButton(
                      onPressed: _confirmBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown[800],
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      child: const Text('Confirm Booking', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }
}