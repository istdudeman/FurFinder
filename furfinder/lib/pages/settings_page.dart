import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Device Management',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.bluetooth_searching, color: Colors.blue),
            title: const Text('Add Beacon'),
            subtitle: const Text('Add and configure a new beacon'),
            onTap: () {
              _showAddDeviceDialog('Beacon');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.wifi_tethering, color: Colors.orange),
            title: const Text('Add Transmitter'),
            subtitle: const Text('Add and configure a new transmitter'),
            onTap: () {
              _showAddDeviceDialog('Transmitter');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.rss_feed, color: Colors.green),
            title: const Text('Add RFID Scanner'),
            subtitle: const Text('Add and configure a new RFID scanner'),
            onTap: () {
              _showAddDeviceDialog('RFID Scanner');
            },
          ),
        ],
      ),
    );
  }

  /// Shows a placeholder dialog for adding a device.
  void _showAddDeviceDialog(String deviceType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add $deviceType'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('This is where you would add a new $deviceType.'),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: '$deviceType ID',
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () {
                // TODO: Implement the logic to add the device
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
