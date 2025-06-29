import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class SensorReadingsApi {
  // 1. Function to insert a new sensor reading
  Future<bool> insertSensorReading({
    required String deviceId,
    required String animalId,
    required double rssi,
    required double power,
    required DateTime timestamp,
  }) async {
    try {
      await supabase.from('sensor_readings').insert({
        'device_id': deviceId,
        'animal_id': animalId,
        'rssi': rssi,
        'power': power,
        'timestamp': timestamp.toIso8601String(),
      });
      print('✅ Sensor reading inserted successfully.');
      return true;
    } catch (e) {
      print('❌ Error inserting sensor reading: $e');
      return false;
    }
  }

  // 2. Function to fetch all sensor readings
  Future<List<Map<String, dynamic>>> fetchAllSensorReadings() async {
    try {
      final response = await supabase
          .from('sensor_readings')
          .select('*')
          .order('timestamp', ascending: false); // Order by latest readings first
      print('✅ All sensor readings fetched successfully.');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching all sensor readings: $e');
      return [];
    }
  }

  // 3. Function to fetch sensor readings for a specific animal_id
  Future<List<Map<String, dynamic>>> fetchSensorReadingsByAnimalId(String animalId) async {
    try {
      final response = await supabase
          .from('sensor_readings')
          .select('*')
          .eq('animal_id', animalId)
          .order('timestamp', ascending: false);
      print('✅ Sensor readings for animal_id $animalId fetched successfully.');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching sensor readings by animal_id: $e');
      return [];
    }
  }

  // 4. Function to delete a sensor reading by its ID
  Future<bool> deleteSensorReading(String id) async {
    try {
      await supabase
          .from('sensor_readings')
          .delete()
          .eq('id', id);
      print('✅ Sensor reading with ID $id deleted successfully.');
      return true;
    } catch (e) {
      print('❌ Error deleting sensor reading: $e');
      return false;
    }
  }

  // 5. Function to update a sensor reading (e.g., if you need to correct data)
  Future<bool> updateSensorReading({
    required String id,
    String? deviceId,
    String? animalId,
    double? rssi,
    double? power,
    DateTime? timestamp,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (deviceId != null) updateData['device_id'] = deviceId;
      if (animalId != null) updateData['animal_id'] = animalId;
      if (rssi != null) updateData['rssi'] = rssi;
      if (power != null) updateData['power'] = power;
      if (timestamp != null) updateData['timestamp'] = timestamp.toIso8601String();

      await supabase
          .from('sensor_readings')
          .update(updateData)
          .eq('id', id);
      print('✅ Sensor reading with ID $id updated successfully.');
      return true;
    } catch (e) {
      print('❌ Error updating sensor reading: $e');
      return false;
    }
  }
}