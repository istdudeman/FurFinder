import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pet_status.dart';

class PetStatusService {
  final _client = Supabase.instance.client;

  Future<List<PetStatus>> fetchLatestPetStatuses(String userId) async {
    final List<dynamic> pets = await _client
        .from('pets')
        .select('animal_id, name')
        .eq('user_id', userId);

    List<PetStatus> results = [];

    for (var pet in pets) {
      final animalId = pet['animal_id'];
      final petName = pet['name'];

      final beacon = await _client
          .from('beacons')
          .select('beacon_id')
          .eq('animal_id', animalId)
          .maybeSingle();

      if (beacon == null) continue;

      final beaconId = beacon['beacon_id'];

      final sensor = await _client
          .from('sensor_readings')
          .select('device_id, timestamp')
          .eq('beacon_id', beaconId)
          .order('timestamp', ascending: false)
          .limit(1)
          .maybeSingle();

      final activity = await _client
          .from('activity_logs')
          .select('description, time_log')
          .eq('animal_id', animalId)
          .order('time_log', ascending: false)
          .limit(1)
          .maybeSingle();

      if (sensor != null) {
        results.add(PetStatus(
          petName: petName,
          deviceId: sensor['device_id'],
          lastSeen: DateTime.parse(sensor['timestamp']),
          activity: activity?['description'],
          activityTime: activity?['time_log'],
        ));
      }
    }

    return results;
  }
}
