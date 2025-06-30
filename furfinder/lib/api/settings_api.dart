// furfinder/lib/api/settings_api.dart
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

Future<void> addBeacon(String deviceId) async {
  final existing = await supabase
      .from('settings')
      .select('id')
      .filter('beacon_id', 'is', null) // Find a row where beacon_id is null
      .limit(1);

  if (existing.isNotEmpty) {
    await supabase
        .from('settings')
        .update({'beacon_id': deviceId})
        .eq('id', existing.first['id']);
  } else {
    // If no row with null beacon_id, insert a new one
    // This will work with the ESP32's upsert if beacon_id has a UNIQUE constraint
    await supabase.from('settings').insert({'beacon_id': deviceId});
  }
}

Future<void> addTransmitter(String deviceId) async {
  final existing = await supabase
      .from('settings')
      .select('id')
      .filter(
        'transmitter_id',
        'is',
        null,
      ) // Find a row where transmitter_id is null
      .limit(1);

  if (existing.isNotEmpty) {
    await supabase
        .from('settings')
        .update({'transmitter_id': deviceId})
        .eq('id', existing.first['id']);
  } else {
    // If no row with null transmitter_id, insert a new one
    // This will work with the ESP32's upsert if transmitter_id has a UNIQUE constraint
    await supabase.from('settings').insert({'transmitter_id': deviceId});
  }
}

Future<void> addRFIDScanner(String animalId) async {
  // This function adds an RFID scanner ID to the pending_pets table.
  // This is separate from the 'settings' table and is used when a new pet
  // is being registered via RFID.
  await supabase.from('pending_pets').insert({'animal_id': animalId});
}

Future<List<Map<String, dynamic>>> fetchSettings() async {
  try {
    final response = await supabase
        .from('settings')
        .select('id, beacon_id, transmitter_id, assigned_pet_id, transmitter_assigned_service, rfid_scanner_id, rfid_scanner_assigned_function') // ADD RFID scanner fields here
        .order('id', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    print('❌ Error fetching all settings: $e');
    return [];
  }
}
Future<void> assignPetToBeacon(String beaconId, String petId) async {
  try {
    await supabase.from('settings').update({
      'assigned_pet_id': petId, // Update the new column
    }).eq('beacon_id', beaconId);

    print('✅ Pet ID "$petId" assigned to Beacon ID "$beaconId" successfully.');
  } catch (e) {
    print('❌ Error assigning pet to beacon: $e');
    rethrow;
  }
}

Future<void> assignServiceToTransmitter(String transmitterId, String serviceName) async {
  try {
    // This will update the row where transmitter_id matches, setting the transmitter_assigned_service
    await supabase.from('settings').update({
      'transmitter_assigned_service': serviceName,
    }).eq('transmitter_id', transmitterId); // Update where transmitter_id matches

    print('✅ Service "$serviceName" assigned to Transmitter ID "$transmitterId" successfully.');
  } catch (e) {
    print('❌ Error assigning service to transmitter: $e');
    rethrow; // Re-throw to handle in UI
  }
}

Future<List<Map<String, dynamic>>> fetchAllUserPets(String userId) async {
  final supabase = Supabase.instance.client;
  try {
    final response = await supabase
        .from('pets')
        .select('animal_id, name, breed'); // Select pet ID and name for the list
        // .eq('user_id', userId); // Uncomment if you want to filter by the current logged-in user's pets

    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    print('❌ Error fetching all user pets: $e');
    return [];
  }
}

Future<void> assignFunctionToRFIDScanner(String rfidScannerId, String functionName) async {
  try {
    await supabase.from('settings').update({
      'rfid_scanner_assigned_function': functionName,
    }).eq('rfid_scanner_id', rfidScannerId); // Update where rfid_scanner_id matches

    print('✅ Function "$functionName" assigned to RFID Scanner ID "$rfidScannerId" successfully.');
  } catch (e) {
    print('❌ Error assigning function to RFID scanner: $e');
    rethrow;
  }
}