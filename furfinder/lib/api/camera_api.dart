import 'package:supabase_flutter/supabase_flutter.dart';

/// Ambil semua animal_id berdasarkan user_id dari tabel pets
Future<List<String>> fetchAnimalIdsByUser(String userId) async {
  final supabase = Supabase.instance.client;

  try {
    final response = await supabase
        .from('pets')
        .select('animal_id')
        .eq('user_id', userId);

    final animalIds = (response as List)
        .map((row) => row['animal_id'] as String)
        .where((id) => id.isNotEmpty)
        .toList();

    print("🐶 Animal IDs milik user $userId: $animalIds");
    return animalIds;
  } catch (e) {
    print("❌ Error fetchAnimalIdsByUser: $e");
    return [];
  }
}

/// Mengembalikan URL kamera dan nama hewan
Future<Map<String, String>?> fetchCameraStreamInfo(List<String> animalIds) async {
  final supabase = Supabase.instance.client;

  try {
    final response = await supabase
        .from('camera')
        .select('url, animal_id')
        .inFilter('animal_id', animalIds);

    print("📦 Kamera ditemukan dari Supabase: $response");

    if (response is List && response.isNotEmpty) {
      for (final row in response) {
        final animalId = row['animal_id'] as String?;
        final url = row['url'] as String?;

        if (animalId != null && url != null && url.isNotEmpty) {
          // Ambil nama hewan dari tabel pets
          final petResponse = await supabase
              .from('pets')
              .select('name')
              .eq('animal_id', animalId)
              .maybeSingle();

          final petName = petResponse?['name'] ?? 'Hewan';

          print("🎥 Kamera aktif: $url untuk hewan: $petName");

          return {
            'url': url,
            'name': petName,
          };
        }
      }
    }

    print("⚠️ Tidak ada kamera aktif untuk animalIds: $animalIds");
    return null;
  } catch (e) {
    print("❌ Error fetchCameraStreamInfo: $e");
    return null;
  }
}

/// Fungsi utama: gabungkan user_id ➝ animal_ids ➝ kamera dan nama hewan
Future<Map<String, String>?> fetchUserCameraStream(String userId) async {
  final animalIds = await fetchAnimalIdsByUser(userId);
  if (animalIds.isEmpty) {
    print("📭 Tidak ada hewan milik user: $userId");
    return null;
  }

  return await fetchCameraStreamInfo(animalIds);
}
