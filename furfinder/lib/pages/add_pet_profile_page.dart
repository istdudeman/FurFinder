import 'package:flutter/material.dart';
import 'package:furfinder/api/pet_api.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';


class AddPetProfilePage extends StatefulWidget {
  const AddPetProfilePage({super.key});

  @override
  State<AddPetProfilePage> createState() => _AddPetProfilePageState();
}

class _AddPetProfilePageState extends State<AddPetProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController breedController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  Future<void> addPetProfile(String name, String breed, int age) async {
    final uuid = Uuid();
    final animalId = uuid.v4(); // generate ID unik untuk hewan

    final result = await addPetData(
      animalId: animalId,
      name: name,
      breed: breed,
      age: age,
    );

    if (result == null) {
      // Sukses
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: const Text("SUCCESS", textAlign: TextAlign.center),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      // Gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    breedController.dispose();
    ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background color curve
          Container(
            height: 280,
            decoration: const BoxDecoration(
              color: Color(0xFFB9C57D),
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(80)),
            ),
          ),

          // Scrollable form content
          SafeArea( // Added SafeArea to avoid status bar overlap
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20), // Adjusted top padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      color: Colors.black, // Ensure visibility
                    ),

                    const SizedBox(height: 10),

                    // Title and Dog emoji (using Row for better layout)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Flexible( // Allows text to wrap if needed
                          child: Text(
                            "Add Pet Profile",
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                          ),
                        ),
                         Padding( // Added padding for better spacing
                           padding: const EdgeInsets.only(top: 20.0),
                           child: Text('🐶', style: const TextStyle(fontSize: 100)),
                         ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Name input
                    const Text(
                      "Pet Name",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: "e.g. Bruno",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                           borderSide: BorderSide.none, // Removed default border
                        ),
                        enabledBorder: OutlineInputBorder( // Style when not focused
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                         focusedBorder: OutlineInputBorder( // Style when focused
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Breed input
                    const Text(
                      "Breed",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: breedController,
                      decoration: InputDecoration(
                        hintText: "e.g. Golden Retriever",
                        filled: true,
                        fillColor: Colors.white,
                         border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                           borderSide: BorderSide.none,
                        ),
                         enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                         focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Age input
                    const Text(
                      "Age",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: ageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "e.g. 3",
                        filled: true,
                        fillColor: Colors.white,
                         border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                           borderSide: BorderSide.none,
                        ),
                         enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                         focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Add Now button
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown[800],
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16), // Adjusted padding
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          final name = nameController.text.trim();
                          final breed = breedController.text.trim();
                          final age = int.tryParse(ageController.text.trim()) ?? 0;

                          if (name.isNotEmpty && breed.isNotEmpty && age > 0) {
                            addPetProfile(name, breed, age);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Harap isi semua data dengan benar")),
                            );
                          }
                        },
                        child: const Text(
                          "ADD NOW",
                          style: TextStyle(color: Colors.white, fontSize: 16), // Adjusted font size
                        ),
                      ),
                    ),
                     const SizedBox(height: 20), // Added padding at the bottom
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}