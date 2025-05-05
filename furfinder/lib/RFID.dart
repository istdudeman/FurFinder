import 'dart:async';

class ESP32Reader {
  bool _connected = false;

  // Simulated connect to device
  Future<bool> connect() async {
    await Future.delayed(const Duration(seconds: 2)); // simulate delay
    _connected = true;
    return _connected;
  }

  // Simulated disconnect from device
  void disconnect() {
    _connected = false;
  }

  // Check connection status
  bool isConnected() {
    return _connected;
  }

  // Simulate reading an RFID tag
  Stream<String> startReadingRFID() async* {
    if (!_connected) {
      throw Exception("Device not connected!");
    }

    // Emit fake RFID UIDs every 3 seconds
    List<String> mockUIDs = [
      "04A3F2456B",
      "0391B7F123",
      "0A8C5E8D2F",
      "07B6D1A93C",
    ];

    for (var uid in mockUIDs) {
      await Future.delayed(const Duration(seconds: 3));
      yield uid;
    }
  }
}
