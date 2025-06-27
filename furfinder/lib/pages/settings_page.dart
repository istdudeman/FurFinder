import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../api/settings_api.dart'; // ganti sesuai struktur project

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  void _showAddDeviceDialog(String deviceType) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add $deviceType'),
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
              onPressed: () {
                final String id = controller.text.trim();
                if (id.isNotEmpty) {
                  _submitDevice(deviceType, id);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitDevice(String deviceType, String deviceId) async {
    try {
      if (deviceType == 'Beacon') {
        await addBeacon(deviceId);
        _showSuccess('Beacon berhasil ditambahkan!');
      } else if (deviceType == 'Transmitter') {
        await addTransmitter(deviceId);
        _showSuccess('Transmitter berhasil ditambahkan!');
      } else if (deviceType == 'RFID Scanner') {
        await addRFIDScanner(deviceId);
        _showSuccess('RFID Scanner berhasil ditambahkan!');
      }
    } catch (e) {
      debugPrint('Insert error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
            onTap: () => _showAddDeviceDialog('Beacon'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.wifi_tethering, color: Colors.orange),
            title: const Text('Add Transmitter'),
            subtitle: const Text('Add and configure a new transmitter'),
            onTap: () => _showAddDeviceDialog('Transmitter'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.rss_feed, color: Colors.green),
            title: const Text('Add RFID Scanner'),
            subtitle: const Text('Add and configure a new RFID scanner'),
            onTap: () => _showAddDeviceDialog('RFID Scanner'),
          ),
        ],
      ),
    );
  }
}
