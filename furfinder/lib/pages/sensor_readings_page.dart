import 'package:flutter/material.dart';
import '../api/sensor_readings_api.dart'; // Import your new API

class SensorReadingsPage extends StatefulWidget {
  const SensorReadingsPage({super.key});

  @override
  State<SensorReadingsPage> createState() => _SensorReadingsPageState();
}

class _SensorReadingsPageState extends State<SensorReadingsPage> {
  List<Map<String, dynamic>> _sensorReadings = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchSensorData();
  }

  Future<void> _fetchSensorData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final api = SensorReadingsApi();
      final data = await api.fetchAllSensorReadings();
      setState(() {
        _sensorReadings = data;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching sensor readings: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Readings'),
        backgroundColor: const Color(0xFFB9C57D),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _sensorReadings.isEmpty
                  ? const Center(child: Text('No sensor readings found.'))
                  : ListView.builder(
                      itemCount: _sensorReadings.length,
                      itemBuilder: (context, index) {
                        final reading = _sensorReadings[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Device ID: ${reading['device_id'] ?? 'N/A'}'),
                                Text('Animal ID: ${reading['animal_id'] ?? 'N/A'}'),
                                Text('RSSI: ${reading['rssi'] ?? 'N/A'}'),
                                Text('Power: ${reading['power'] ?? 'N/A'}'),
                                Text('Timestamp: ${reading['timestamp'] ?? 'N/A'}'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Example of inserting data
          final api = SensorReadingsApi();
          final success = await api.insertSensorReading(
            deviceId: 'dev_001',
            animalId: 'pet_xyz',
            rssi: -75.5,
            power: 10.2,
            timestamp: DateTime.now(),
          );
          if (success) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sensor reading added!')),
              );
              _fetchSensorData(); // Refresh the list
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to add sensor reading.')),
              );
            }
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}