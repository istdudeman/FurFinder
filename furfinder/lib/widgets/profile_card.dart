import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProfileCard extends StatefulWidget {
  final String petID;

  const ProfileCard({Key? key, required this.petID}) : super(key: key);

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  Map<String, dynamic>? petData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPetData();
  }

  Future<void> fetchPetData() async {
    final url = Uri.parse(
        'https://c34b-182-253-50-98.ngrok-free.app/api/pets/${widget.petID}');
    print("Pet ID yang dikirim: ${widget.petID}");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          petData = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        print("Gagal mendapatkan data hewan: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching data pets: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || petData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D1BD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueAccent, width: 2),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white,
            child: Text('🐶', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  petData!['name'] ?? 'Nama tidak ada',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  petData!['service'] ?? 'Jenis layanan',
                  style: const TextStyle(color: Colors.black54),
                ),
                Text(
                  petData!['location'] ?? 'Alamat toko tidak tersedia',
                  style: const TextStyle(color: Colors.black45, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                petData!['day']?.toString() ?? "0",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                petData!['month'] ?? "Unknown",
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
