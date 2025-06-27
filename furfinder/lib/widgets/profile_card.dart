import 'package:flutter/material.dart';
import '../api/pet_api.dart'; // Tambahkan ini

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
    loadData();
  }

  Future<void> loadData() async {
    final data = await fetchPetProfileData(widget.petID);

    if (data == null) {
      print("Data tidak ditemukan atau error.");
      return;
    }

    setState(() {
      petData = data;
      isLoading = false;
    });
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
                petData!['day'].toString(),
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