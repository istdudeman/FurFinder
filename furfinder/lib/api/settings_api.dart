import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

Future<void> addBeacon(String deviceId) async {
  final existing = await supabase
      .from('settings')
      .select()
      .filter('beacon_id', 'is', null)
      .limit(1);

  if (existing.isNotEmpty) {
    await supabase
        .from('settings')
        .update({'beacon_id': deviceId})
        .eq('id', existing.first['id']);
  } else {
    await supabase.from('settings').insert({'beacon_id': deviceId});
  }
}

Future<void> addTransmitter(String deviceId) async {
  final existing = await supabase
      .from('settings')
      .select()
      .filter('transmitter_id', 'is', null)
      .limit(1);

  if (existing.isNotEmpty) {
    await supabase
        .from('settings')
        .update({'transmitter_id': deviceId})
        .eq('id', existing.first['id']);
  } else {
    await supabase.from('settings').insert({'transmitter_id': deviceId});
  }
}

Future<void> addRFIDScanner(String animalId) async {
  await supabase.from('pending_pets').insert({'animal_id': animalId});
}