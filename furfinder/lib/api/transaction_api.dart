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
  required String userId,
  required String cageId,
  required String serviceId,
  required DateTime startDate,
  required DateTime endDate,
  required double totalPrice,
}) async {
  final uuid = const Uuid();
  final bookingId = uuid.v4();

  try {
    // Ambil user yang sedang login
    final currentUser = supabase.auth.currentUser;

    if (currentUser == null) {
      print('❌ Tidak ada user yang login');
      return false;
    }

    final userId = currentUser.id;

    // Verifikasi animal_id di tabel pets
    final petResponse = await supabase
        .from('pets')
        .select('animal_id')
        .eq('animal_id', petId)
        .maybeSingle();

    if (petResponse == null || petResponse['animal_id'] == null) {
      print('❌ animal_id tidak ditemukan di pets untuk petId: $petId');
      return false;
    }

    final animalId = petResponse['animal_id'];

    // Ambil rfid_tag terbaru dari pending_pets
    final pendingPet = await supabase
        .from('pending_pets')
        .select('rfid_tag')
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (pendingPet != null && pendingPet['rfid_tag'] != null) {
      final rfidTag = pendingPet['rfid_tag'];

      // Update pets.rfid_tag
      await supabase.from('pets').update({
        'rfid_tag': rfidTag,
      }).eq('animal_id', petId);

      // Hapus rfid_tag dari pending_pets setelah berhasil diinput
      await supabase
          .from('pending_pets')
          .delete()
          .eq('rfid_tag', rfidTag);
    } else {
      print('⚠️ Tidak ditemukan rfid_tag dari pending_pets');
    }

    // Insert booking with 'pending_payment' status
    await supabase.from('bookings').insert({
      'booking_id': bookingId,
      'user_id': userId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': 'pending_payment', // Changed status to pending_payment
      'total_price': totalPrice,
      'animal_id': animalId,
      'cage_id': cageId,
      'services_id': serviceId,
    });

    // IMPORTANT: The updateCageStatus should ideally happen only after
    // the payment is manually confirmed by an administrator.
    // Consider moving this logic to an admin-specific function or process.
    // await updateCageStatus(cageId, animalId);

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

// New function to confirm payment by user
Future<bool> confirmPaymentMade(String bookingId, String userId) async {
  try {
    // Update booking status to 'payment_confirmed_by_user'
    await supabase.from('bookings').update({
      'status': 'payment_confirmed_by_user',
    }).eq('booking_id', bookingId).eq('user_id', userId); //

    // Add activity log for admin to see
    await supabase.from('activity_logs').insert({
      'description': 'User has confirmed payment for booking $bookingId.',
      'time_log': DateTime.now().toIso8601String(),
      'pet_name': 'Payment Confirmation', // Placeholder, ideally fetch pet name
      'animal_id': bookingId, // Using bookingId for context
    });

    return true;
  } catch (e) {
    print('❌ Error confirming payment: $e');
    return false;
  }
}