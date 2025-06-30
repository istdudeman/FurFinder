import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api/transaction_api.dart';

class TransactionPage extends StatefulWidget {
  final String petID;
  final String? serviceID;

  const TransactionPage({super.key, required this.petID, this.serviceID});

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
  String _errorMessage = ''; // Declare _errorMessage here

  @override
  void initState() {
    super.initState();
    // Initialize _selectedServiceId here, but it will be re-validated in _fetchInitialData
    _selectedServiceId = widget.serviceID;
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    try {
      final pet = await fetchPetDetails(widget.petID);
      final services = await fetchServices();
      final cages = await fetchCages();

      setState(() {
        _petDetails = pet;
        _services = services;
        _cages = cages;

        // NEW LOGIC: Check if the initial serviceID exists in the fetched services
        if (widget.serviceID != null && _services.any((service) => service['services_id'] == widget.serviceID)) {
          _selectedServiceId = widget.serviceID;
        } else {
          // If the serviceID is not found or null, ensure no service is pre-selected
          _selectedServiceId = null;
        }
      });
      _calculatePrice();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Error loading data: $e"; // Assign error message
          _isLoading = false; // Set loading to false on error
        });
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

  void _calculatePrice() {
    if (_startDate == null || _endDate == null || _selectedCageId == null || _selectedServiceId == null) {
      setState(() {
        _totalPrice = 0; // Reset total price if any required field is missing
      });
      return;
    }

    final days = _endDate!.difference(_startDate!).inDays;
    if (days >= 0) { // Should be days >= 0
      final cage = _cages.firstWhere((c) => c['cage_id'] == _selectedCageId);
      final service = _services.firstWhere((s) => s['services_id'] == _selectedServiceId);
      final cagePricePerDay = (cage['price_per_day'] as num).toDouble();
      final servicePrice = (service['price'] as num).toDouble();

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
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
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
    const userId = 'e993c4f1-b374-4cf9-af7a-c1a683f2f29d'; // Consider fetching dynamically if possible

    if (_startDate == null || _endDate == null || _selectedCageId == null || _selectedServiceId == null || _totalPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields and ensure the dates are correct.")),
      );
      return;
    }

    final cageStatus = await checkCageStatus(_selectedCageId!);

    if (cageStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cage not found.")),
      );
      return;
    }

    if (cageStatus == 'occupied') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cage is already occupied.")),
      );
      return;
    }

      final success = await insertBooking(
        petId: widget.petID,
        cageId: _selectedCageId!,
        serviceId: _selectedServiceId!,
        startDate: _startDate!,
        endDate: _endDate!,
        totalPrice: _totalPrice,
        userId: userId,
    );

    if (success) {
      // The updateCageStatus is intentionally commented out in transaction_api.dart
      // for manual admin confirmation. If it were to be updated automatically,
      // it would be called here.
      // final updateSuccess = await updateCageStatus(_selectedCageId!, widget.petID);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking successful! Payment confirmation pending admin verification.")),
      );
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.of(context).pop();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking failed.")),
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
          : _errorMessage.isNotEmpty // Use _errorMessage here
              ? Center(child: Text(_errorMessage)) // Display error message
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
                        // Add hint text for when no value is selected
                        hint: const Text('Select a Service'),
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
                        hint: const Text('Select a Cage'), // Add hint for cage selection
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