import 'package:supabase_flutter/supabase_flutter.dart';

/// Menambahkan data hewan dari pending_pets ke tabel pets
Future<String?> addPetData({
  required String userId,
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

    // 2. Insert ke tabel pets (animal_id akan di-generate otomatis)
    await supabase.from('pets').insert({
      'user_id': user.id,
      'name': name,
      'breed': breed,
      'age': age,
    });

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
