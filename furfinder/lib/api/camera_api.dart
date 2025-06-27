import 'package:supabase_flutter/supabase_flutter.dart';

Future<String?> fetchCameraStreamUrl(String animalId) async {
  final supabase = Supabase.instance.client;

  try {
    final response = await supabase
        .from('camera')
        .select('url')
        .eq('animal_id', animalId)
        .maybeSingle();

    if (response != null && response['url'] != null) {
      return response['url'] as String;
    } else {
      return null; // Tidak ditemukan atau kosong
    }
  } catch (e) {
    print("❌ Error in fetchCameraStreamUrl: $e");
    return null;
  }
}