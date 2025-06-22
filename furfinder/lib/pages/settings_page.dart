import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Ubah baseUrl sesuai endpoint kamu (gunakan IP lokal atau ngrok)
  final String baseUrl = 'https://b5a5-2404-8000-1015-1a6b-a543-94e7-e667-22f3.ngrok-free.app';

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

  void _showAddDeviceDialog(String deviceType) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add $deviceType'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: controller,
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
    String url;
    Map<String, dynamic> body;

    // Penyesuaian endpoint dan payload berdasarkan deviceType
    if (deviceType == 'Beacon') {
      url = '$baseUrl/api/settings/addbeacon';
      body = {'beacon_id': deviceId};
    } else if (deviceType == 'Transmitter') {
      url = '$baseUrl/api/settings/addtransmitter';
      body = {'transmitter_id': deviceId};
    } else if (deviceType == 'RFID Scanner') {
      url = '$baseUrl/api/pets/rfid';
      body = {'rfid': deviceId};
    } else {
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$deviceType berhasil ditambahkan!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan $deviceType')),
        );
        print('Server response: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }
}
