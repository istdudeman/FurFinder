// pages/activity_log_page.dart
import 'package:flutter/material.dart';
import '../models/activity_logs.dart'; // Adjust import path as needed

class ActivityLogPage extends StatefulWidget {
  const ActivityLogPage({super.key});

  @override
  State<ActivityLogPage> createState() => _ActivityLogPageState();
}

class _ActivityLogPageState extends State<ActivityLogPage> {
  // Sample data - replace with your actual data source
  final List<ActivityLogEntry> _activityLogs = [
    ActivityLogEntry(time: "07:44", description: "Keluar Kandang", dotColor: Colors.redAccent.shade100),
    ActivityLogEntry(time: "03:05", description: "Masuk Kandang", dotColor: Colors.greenAccent.shade200),
    ActivityLogEntry(time: "02:00", description: "sedang Haircut", dotColor: Colors.brown.shade300),
    ActivityLogEntry(time: "12:18", description: "Keluar Kandang", dotColor: Colors.redAccent.shade100),
    ActivityLogEntry(time: "21:30", description: "Masuk Kandang", dotColor: Colors.greenAccent.shade200),
    ActivityLogEntry(time: "21:20", description: "sedang NailTrim", dotColor: Colors.orange.shade300),
    ActivityLogEntry(time: "20:30", description: "Keluar Kandang", dotColor: Colors.redAccent.shade100),
    ActivityLogEntry(time: "19:45", description: "Masuk Kandang", dotColor: Colors.greenAccent.shade200),
    ActivityLogEntry(time: "17:57", description: "sedang Bathing", dotColor: Colors.blueGrey.shade200),
  ];

  final String _petName = "Aasyifa";
  final String _petAddress = "Alamat Toko Peliharaan"; // Example address

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
                child: ListView.builder(
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