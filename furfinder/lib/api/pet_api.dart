import 'package:supabase_flutter/supabase_flutter.dart';

/// Menambahkan data hewan dari pending_pets ke tabel pets

Future<String?> addPetData({
  required String animalId,
  required String name,
  required String breed,
  required int age,
}) async {
  final supabase = Supabase.instance.client;

  try {
    // Ambil user_id dari akun yang login
    final user = supabase.auth.currentUser;
    if (user == null) {
      return 'Pengguna belum login.';
    }

    // Ambil satu rfid_tag dari pending_pets
    final pendingPet = await supabase
        .from('pending_pets')
        .select('rfid_tag')
        .limit(1)
        .maybeSingle();

    if (pendingPet == null || pendingPet['rfid_tag'] == null) {
      return 'Data pending tidak ditemukan atau rfid_tag kosong.';
    }

    final rfidTag = pendingPet['rfid_tag'];

    // Insert ke tabel pets
    await supabase.from('pets').insert({
      'animal_id': animalId,
      'user_id': user.id,
      'name': name,
      'breed': breed,
      'age': age,
      'rfid_tag': rfidTag,
    });

    // Hapus entri dari pending_pets berdasarkan rfid_tag
    await supabase
        .from('pending_pets')
        .delete()
        .eq('rfid_tag', rfidTag);

    return null; // Berhasil
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
