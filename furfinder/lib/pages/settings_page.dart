// furfinder/lib/pages/settings_page.dart

import 'package:flutter/material.dart';
import 'package:furfinder/api/settings_api.dart' as settings_api;
import 'package:furfinder/api/transaction_api.dart' as transaction_api; // For services
import 'package:furfinder/api/pet_api.dart' as pet_api; // For pets

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<Map<String, dynamic>> _registeredDevices = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchAndDisplaySettings();
  }

  Future<void> _fetchAndDisplaySettings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final allSettings = await settings_api.fetchSettings();

      if (mounted) {
        setState(() {
          if (allSettings.isNotEmpty) {
            _registeredDevices = allSettings;
          } else {
            _errorMessage = 'No settings data found.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading settings: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showAddDeviceDialog(String deviceType) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add $deviceType (Manual)'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: '$deviceType ID',
              border: const OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () async {
                final String id = controller.text.trim();
                if (id.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("ID cannot be empty.")),
                  );
                  return;
                }

                try {
                  if (deviceType == 'Beacon') {
                    await settings_api.addBeacon(id);
                    _showSuccess('Beacon ID manually added/saved!');
                  } else if (deviceType == 'Transmitter') {
                    await settings_api.addTransmitter(id);
                    _showSuccess('Transmitter ID manually added/saved!');
                  } else if (deviceType == 'RFID Scanner') {
                    await settings_api.addRFIDScanner(id);
                    _showSuccess('RFID Scanner ID added to pending list!');
                  }
                  _fetchAndDisplaySettings();
                  if (mounted) Navigator.of(context).pop();
                } catch (e) {
                  debugPrint('Manual add error: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error adding manually: $e')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showAssignPetDialog(String beaconId) async {
    String? selectedPetId;
    String? selectedPetName;
    List<Map<String, dynamic>> pets = [];
    bool fetchingPets = true;

    try {
      pets = await pet_api.fetchAllUserPets('');
      fetchingPets = false;
    } catch (e) {
      debugPrint('Error fetching pets: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load pets: $e')),
        );
      }
      fetchingPets = false;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return AlertDialog(
              title: Text('Assign Pet to Beacon\nID: $beaconId'),
              content: fetchingPets
                  ? const Center(child: CircularProgressIndicator())
                  : pets.isEmpty
                      ? const Text('No pets available.')
                      : DropdownButtonFormField<String>(
                          value: selectedPetId,
                          hint: const Text('Select Pet'),
                          items: pets.map<DropdownMenuItem<String>>((pet) {
                            return DropdownMenuItem<String>(
                              value: pet['animal_id'],
                              child: Text(pet['name']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setStateSB(() {
                              selectedPetId = value;
                              selectedPetName = pets.firstWhere((p) => p['animal_id'] == value)['name'];
                            });
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Pet',
                          ),
                        ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  child: const Text('Assign'),
                  onPressed: selectedPetId == null
                      ? null
                      : () async {
                          try {
                            await settings_api.assignPetToBeacon(beaconId, selectedPetId!);
                            _showSuccess('Pet "$selectedPetName" assigned to Beacon ID "$beaconId" successfully!');
                            _fetchAndDisplaySettings();
                            if (mounted) Navigator.of(context).pop();
                          } catch (e) {
                            debugPrint('Error assigning pet: $e');
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to assign pet: $e')),
                              );
                            }
                          }
                        },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAssignServiceDialog(String deviceId, String deviceType) async {
    String? selectedServiceId;
    List<dynamic> services = [];
    bool fetchingServices = true;

    try {
      services = await transaction_api.fetchServices();
      fetchingServices = false;
    } catch (e) {
      debugPrint('Error fetching services: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load services: $e')),
        );
      }
      fetchingServices = false;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return AlertDialog(
              title: Text('Assign Service to $deviceType\nID: $deviceId'),
              content: fetchingServices
                  ? const Center(child: CircularProgressIndicator())
                  : services.isEmpty
                      ? const Text('No services available.')
                      : DropdownButtonFormField<String>(
                          value: selectedServiceId,
                          hint: const Text('Select Service'),
                          items: services.map<DropdownMenuItem<String>>((service) {
                            return DropdownMenuItem<String>(
                              value: service['services_id'],
                              child: Text(service['services_name']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setStateSB(() {
                              selectedServiceId = value;
                            });
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Service',
                          ),
                        ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  child: const Text('Assign'),
                  onPressed: selectedServiceId == null
                      ? null
                      : () async {
                          final selectedServiceName = services.firstWhere(
                              (s) => s['services_id'] == selectedServiceId)['services_name'];

                          try {
                            if (deviceType == 'Transmitter') {
                              await settings_api.assignServiceToTransmitter(deviceId, selectedServiceName);
                            }
                            _showSuccess('Service assigned successfully!');
                            _fetchAndDisplaySettings();
                            if (mounted) Navigator.of(context).pop();
                          } catch (e) {
                            debugPrint('Error assigning service: $e');
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to assign service: $e')),
                              );
                            }
                          }
                        },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // NEW FUNCTION: Dialog to assign a FUNCTION/ROLE to an RFID Scanner
  void _showAssignFunctionToRFIDScannerDialog(String rfidScannerId) async {
    // For simplicity, let's hardcode some common RFID scanner functions/roles
    // In a real app, these might come from another table in your database.
    final List<String> functions = [
      'Entry Gate',
      'Exit Gate',
      'Grooming Station',
      'Feeding Station',
      'Medical Check-in',
      'Inventory Scanner',
    ];
    String? selectedFunction;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return AlertDialog(
              title: Text('Assign Function to RFID Scanner\nID: $rfidScannerId'),
              content: functions.isEmpty
                  ? const Text('No functions defined.')
                  : DropdownButtonFormField<String>(
                      value: selectedFunction,
                      hint: const Text('Select Function'),
                      items: functions.map<DropdownMenuItem<String>>((func) {
                        return DropdownMenuItem<String>(
                          value: func,
                          child: Text(func),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setStateSB(() {
                          selectedFunction = value;
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Function',
                      ),
                    ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  child: const Text('Assign'),
                  onPressed: selectedFunction == null
                      ? null
                      : () async {
                          try {
                            await settings_api.assignFunctionToRFIDScanner(rfidScannerId, selectedFunction!);
                            _showSuccess('Function "$selectedFunction" assigned to RFID Scanner ID "$rfidScannerId" successfully!');
                            _fetchAndDisplaySettings();
                            if (mounted) Navigator.of(context).pop();
                          } catch (e) {
                            debugPrint('Error assigning function to RFID scanner: $e');
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to assign function: $e')),
                              );
                            }
                          }
                        },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // Helper function to get pet name from ID (if fetching all pets by name is too much)
  // This will fetch individual pet data which can be inefficient if many beacons are assigned
  // a pet. A better approach would be to join in the fetchSettings query or cache pet names.
  Future<String> _getPetName(String petId) async {
    if (petId.isEmpty) return 'No Pet Assigned'; // Changed default text
    try {
      final petProfile = await pet_api.fetchPetProfileData(petId);
      return petProfile?['name'] ?? 'Unknown Pet';
    } catch (e) {
      debugPrint('Error fetching pet name for $petId: $e');
      return 'Error fetching name';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
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
              ? Center(child: Text(_errorMessage))
              : ListView(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Registered Devices',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    if (_registeredDevices.isEmpty)
                      const ListTile(
                        title: Text('No devices registered yet.'),
                        subtitle: Text('Add manually below, or ensure ESP devices are active.'),
                      ),
                    ..._registeredDevices.map((device) {
                      final beaconId = device['beacon_id'] as String?;
                      final transmitterId = device['transmitter_id'] as String?; // Fixed typo: was device_id
                      final rfidScannerId = device['rfid_scanner_id'] as String?; // Get RFID scanner ID
                      final assignedPetId = device['assigned_pet_id'] as String?;
                      final transmitterAssignedService = device['transmitter_assigned_service'] as String?;
                      final rfidScannerAssignedFunction = device['rfid_scanner_assigned_function'] as String?; // Get RFID scanner function
                      final rowId = device['id'];

                      if (beaconId != null && beaconId.isNotEmpty) {
                        return Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.bluetooth_searching, color: Colors.blue),
                              title: Text('Beacon ID: $beaconId (Row: $rowId)'),
                              subtitle: FutureBuilder<String>(
                                future: _getPetName(assignedPetId ?? ''),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Text('Assigned Pet: Loading...');
                                  }
                                  return Text(snapshot.data != null && snapshot.data!.isNotEmpty
                                      ? 'Assigned Pet: ${snapshot.data}'
                                      : 'No pet assigned');
                                },
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.pets, color: Colors.grey),
                                onPressed: () => _showAssignPetDialog(beaconId),
                                tooltip: 'Assign Pet',
                              ),
                            ),
                            const Divider(),
                          ],
                        );
                      } else if (transmitterId != null && transmitterId.isNotEmpty) {
                        return Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.wifi_tethering, color: Colors.orange),
                              title: Text('Transmitter ID: $transmitterId (Row: $rowId)'),
                              subtitle: Text(transmitterAssignedService != null && transmitterAssignedService.isNotEmpty
                                  ? 'Assigned Service: $transmitterAssignedService'
                                  : 'No service assigned'),
                              trailing: IconButton(
                                icon: const Icon(Icons.assignment, color: Colors.grey),
                                onPressed: () => _showAssignServiceDialog(transmitterId, 'Transmitter'),
                                tooltip: 'Assign Service',
                              ),
                            ),
                            const Divider(),
                          ],
                        );
                      } else if (rfidScannerId != null && rfidScannerId.isNotEmpty) { // NEW RFID SCANNER DISPLAY
                        return Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.rss_feed, color: Colors.green),
                              title: Text('RFID Scanner ID: $rfidScannerId (Row: $rowId)'),
                              subtitle: Text(rfidScannerAssignedFunction != null && rfidScannerAssignedFunction.isNotEmpty
                                  ? 'Assigned Function: $rfidScannerAssignedFunction'
                                  : 'No function assigned'),
                              trailing: IconButton(
                                icon: const Icon(Icons.settings_input_antenna, color: Colors.grey), // A more generic icon for scanner function
                                onPressed: () => _showAssignFunctionToRFIDScannerDialog(rfidScannerId), // Call new function assignment dialog
                                tooltip: 'Assign Function',
                              ),
                            ),
                            const Divider(),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    }).toList(),
                    // Always show manual add buttons
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Manual Registration/Add',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.bluetooth_searching, color: Colors.blue),
                      title: const Text('Add New Beacon (Manual)'),
                      subtitle: const Text('Manually add a beacon ID to an available row.'),
                      onTap: () => _showAddDeviceDialog('Beacon'),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.wifi_tethering, color: Colors.orange),
                      title: const Text('Add New Transmitter (Manual)'),
                      subtitle: const Text('Manually add a transmitter ID to an available row.'),
                      onTap: () => _showAddDeviceDialog('Transmitter'),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.rss_feed, color: Colors.green),
                      title: const Text('Add RFID Scanner (Manual)'),
                      subtitle: const Text('Add a new RFID scanner to pending list'),
                      onTap: () => _showAddDeviceDialog('RFID Scanner'),
                    ),
                  ],
                ),
    );
  }
}