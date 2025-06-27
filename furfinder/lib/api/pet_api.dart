import 'package:supabase_flutter/supabase_flutter.dart';

Future<String?> addPetData({
  required String userId,
  required String name,
  required String breed,
  required int age,
}) async {
  final supabase = Supabase.instance.client;

  try {
    // 1. Ambil 1 animal_id dari tabel pending_pets
    final pendingResponse = await supabase
        .from('pending_pets')
        .select('animal_id')
        .limit(1)
        .maybeSingle();

    final animalId = pendingResponse?['animal_id'];

    if (animalId == null) {
      return 'Tidak ada data RFID yang tersedia di pending_pets.';
    }

    // 2. Insert ke tabel pets
    final insertResponse = await supabase.from('pets').insert({
      'animal_id': animalId,
      'user_id': userId,
      'name': name,
      'breed': breed,
      'age': age,
      'services': null,
      'date': DateTime.now().toIso8601String(),
    });

    if (insertResponse != null && insertResponse.error != null) {
      return 'Gagal menyimpan ke tabel pets: ${insertResponse.error!.message}';
    }

    // 3. Hapus dari pending_pets setelah sukses insert
    final deleteResponse = await supabase
        .from('pending_pets')
        .delete()
        .eq('animal_id', animalId);

    if (deleteResponse != null && deleteResponse.error != null) {
      return 'Data berhasil ditambahkan, tetapi gagal menghapus dari pending_pets: ${deleteResponse.error!.message}';
    }

    return null; // Sukses
  } catch (e) {
    return 'Terjadi kesalahan: $e';
  }
}

Future<Map<String, dynamic>?> fetchPetProfileData(String petId) async {
  final supabase = Supabase.instance.client;

  try {
    // Ambil data hewan dari tabel pets
    final pet = await supabase
        .from('pets')
        .select()
        .eq('animal_id', petId)
        .maybeSingle();

    if (pet == null) return null;

    // Ambil booking terakhir
    final booking = await supabase
        .from('bookings')
        .select()
        .eq('animal_id', petId)
        .order('start_date', ascending: false)
        .limit(1)
        .maybeSingle();

    String? servicesName;
    DateTime? startDate;

    if (booking != null) {
      final serviceId = booking['services_id'];
      startDate = DateTime.tryParse(booking['start_date']);

      final service = await supabase
          .from('services')
          .select('services_name')
          .eq('services_id', serviceId)
          .maybeSingle();

      servicesName = service?['services_name'] ?? 'Tidak diketahui';
    }

    // Gabungkan data untuk ditampilkan
    return {
      'name': pet['name'],
      'service': servicesName ?? 'Belum ada layanan',
      'location': 'Alamat tidak tersedia', // Ganti jika ada data lokasi
      'day': startDate?.day ?? 0,
      'month': startDate != null ? _monthName(startDate.month) : 'Unknown',
    };
  } catch (e) {
    print('Error fetching pet profile data: $e');
    return null;
  }
}

String _monthName(int month) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];
  return months[month - 1];
}
