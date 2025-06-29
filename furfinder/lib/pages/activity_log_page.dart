// furfinder/lib/pages/activity_log_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../api/sensor_readings_api.dart'; // Import your new API
import 'sensor_readings_page.dart'; // Import the new SensorReadingsPage

// Assuming you still use this model
class ActivityLogEntry {
  final String time;
  final String description;
  final Color dotColor;
  final String petName; // Now this can be dynamic

  ActivityLogEntry({
    required this.time,
    required this.description,
    required this.dotColor,
    required this.petName,
  });
}

class ActivityLogPage extends StatefulWidget {
  const ActivityLogPage({super.key});

  @override
  State<ActivityLogPage> createState() => _ActivityLogPageState();
}

class _ActivityLogPageState extends State<ActivityLogPage> {
  List<ActivityLogEntry> _activityLogs = [];
  bool _isLoading = true;
  String _petName = "Loading..."; // Placeholder for dynamic pet name
  String _petAddress = "Loading..."; // Placeholder for dynamic address
  Map<String, dynamic>? _latestSensorReading; // Added for sensor summary

  @override
  void initState() {
    super.initState();
    _fetchActivityLogs();
    _fetchSensorSummary(); // Call this to fetch sensor data
  }

  Future<void> _fetchActivityLogs() async {
    try {
      final supabase = Supabase.instance.client;
      // Get the current authenticated user's ID
      final currentUserId = supabase.auth.currentUser?.id;

      if (currentUserId == null) {
        // Handle case where user is not logged in
        debugPrint('User not logged in. Cannot fetch activity logs.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please log in to view activity logs.')),
          );
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      // Fetch user profile to get pet name and address
      final userProfile = await supabase
          .from('users')
          .select('name, address, role')
          .eq('id', currentUserId)
          .maybeSingle();

      // Set default values if user profile is not found
      String fetchedUserName = "Unknown User";
      String fetchedUserAddress = "Unknown Address";
      // String userRole = "customer"; // Default to customer if not found (not strictly needed for this part)

      if (userProfile != null) {
        fetchedUserName = userProfile['name'] as String? ?? "Unknown User";
        fetchedUserAddress = userProfile['address'] as String? ?? "Unknown Address";
        // userRole = userProfile['role'] as String? ?? "customer";
      }

      final response = await supabase
          .from('activity_logs')
          .select('time_log, description, pet_name, animal_id')
          .order('time_log', ascending: false)
          .limit(10);

      final fetchedLogs = response.map<ActivityLogEntry>((row) {
        final DateTime logTime = DateTime.parse(row['time_log']);
        final String displayPetName = row['pet_name'] as String? ?? fetchedUserName;

        return ActivityLogEntry(
          time: DateFormat('HH:mm').format(logTime),
          description: row['description'] as String,
          dotColor: _getColorFromDescription(row['description'] as String),
          petName: displayPetName,
        );
      }).toList();

      setState(() {
        _activityLogs = fetchedLogs;
        _petName = fetchedUserName;
        _petAddress = fetchedUserAddress;
        _isLoading = false;
      });
    } on PostgrestException catch (e) {
        debugPrint('Postgrest Error fetching activity logs or user profile: ${e.message}');
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to load activity log (DB error): ${e.message}')),
            );
            setState(() {
                _isLoading = false;
            });
        }
    } catch (e) {
      debugPrint('General Error fetching activity logs or user profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load activity log: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // New method to fetch sensor summary
  Future<void> _fetchSensorSummary() async {
    try {
      final api = SensorReadingsApi(); // Instantiate your API
      final readings = await api.fetchAllSensorReadings(); // Or filter by animalId
      if (readings.isNotEmpty) {
        setState(() {
          _latestSensorReading = readings.first; // Get the most recent one
        });
      }
    } catch (e) {
      debugPrint('Error fetching sensor summary: $e');
    }
  }

  // Helper function to assign colors based on activity description
  Color _getColorFromDescription(String description) {
    if (description.contains("Keluar Kandang")) {
      return Colors.redAccent.shade100;
    } else if (description.contains("Masuk Kandang")) {
      return Colors.greenAccent.shade200;
    } else if (description.contains("Haircut")) {
      return Colors.brown.shade300;
    } else if (description.contains("NailTrim")) {
      return Colors.orange.shade300;
    } else if (description.contains("Bathing")) {
      return Colors.blueGrey.shade200;
    }
    return Colors.grey.shade400; // Default color
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF303030), // Dark background for the page
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Custom AppBar
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Activity Log',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(), // Pushes the next icon to the end
                  IconButton(
                    icon: const Icon(Icons.sensors, color: Colors.white70), // New sensor icon
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SensorReadingsPage(), // Navigate to sensor readings page
                        ),
                      );
                    },
                    tooltip: 'View Sensor Readings',
                  ),
                ],
              ),
            ),
            // Date and Pet Info Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Today',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _petAddress, // Using variable for address
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  Text(
                    _petName, // Using variable for pet name
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  if (_latestSensorReading != null) // Display sensor summary
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        'Latest RSSI: ${_latestSensorReading!['rssi']} dBm at ${DateFormat('HH:mm').format(DateTime.parse(_latestSensorReading!['timestamp']))}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.greenAccent.shade100,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Timeline List Section
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white, // Background color for the log area
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.brown))
                    : _activityLogs.isEmpty
                        ? const Center(child: Text('No activity logs found.', style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 8.0),
                            itemCount: _activityLogs.length,
                            itemBuilder: (context, index) {
                              final activity = _activityLogs[index];
                              final bool isLastItem = index == _activityLogs.length - 1;
                              return _buildActivityItem(activity, isLastItem);
                            },
                          ),
              ),
            ),
            const SizedBox(height: 20), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(ActivityLogEntry activity, bool isLastItem) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0), // Horizontal padding for items
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Timestamp column
          Container(
            width: 55.0, // Adjusted width for timestamp
            padding: const EdgeInsets.only(top: 3.0),
            child: Text(
              activity.time,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              textAlign: TextAlign.right,
            ),
          ),
          // Timeline (Dot and Line) column
          Container(
            width: 30, // Width for the dot and line area
            margin: const EdgeInsets.only(left: 8.0, right: 12.0), // Spacing around dot/line
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 12.0,
                  height: 12.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: activity.dotColor,
                  ),
                ),
                if (!isLastItem)
                  Container(
                    width: 1.5, // Thickness of the line
                    height: 50.0, // Height of the line, adjust for spacing
                    color: Colors.grey.shade300,
                  ),
                if (isLastItem) // Add some space for the last item if no line
                  const SizedBox(height: 50.0),
              ],
            ),
          ),
          // Activity Text column
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(top: 2.0, bottom: 16.0),
              child: Text(
                "${activity.petName} ${activity.description}", // Combining pet name and description
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }
}