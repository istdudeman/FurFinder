import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

final supabase = Supabase.instance.client;

Future<Map<String, dynamic>> fetchPetDetails(String petID) async {
  final response = await supabase
      .from('pets')
      .select()
      .eq('animal_id', petID)
      .single();
  return response;
}

Future<List<dynamic>> fetchServices() async {
  final response = await supabase.from('services').select();
  return response;
}

Future<List<dynamic>> fetchCages() async {
  final response = await supabase.from('cage').select();
  return response;
}

Future<String?> checkCageStatus(String cageId) async {
  final response = await supabase
      .from('cage')
      .select('status')
      .eq('cage_id', cageId)
      .maybeSingle();
  return response?['status'];
}

Future<bool> insertBooking({
  required String petId,
  required String cageId,
  required String serviceId,
  required DateTime startDate,
  required DateTime endDate,
  required double totalPrice,
  required String userId,
}) async {
  final uuid = const Uuid();
  final bookingId = uuid.v4();

  try {
    await supabase.from('bookings').insert({
      'booking_id': bookingId,
      'user_id': userId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': 'confirmed',
      'total_price': totalPrice,
      'animal_id': petId,
      'cage_id': cageId,
      'services_id': serviceId,
    });
    return true;
  } catch (e) {
    print('❌ Error inserting booking: $e');
    return false;
  }
}

Future<bool> updateCageStatus(String cageId, String animalId) async {
  try {
    await supabase.from('cage').update({
      'status': 'occupied',
      'animal_id': animalId,
    }).eq('cage_id', cageId);
    return true;
  } catch (e) {
    print('❌ Error updating cage: $e');
    return false;
  }
}