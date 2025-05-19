import 'package:flutter/material.dart';
import 'camera_view_page.dart';

// -------------------- USER ROLE --------------------
enum UserRole { admin, customer }

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fur Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Sans'),
      home: const RoleSelectionPage(),
    );
  }
}

// -------------------- ROLE SELECTION --------------------
class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Select Role",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PetHomePage(role: UserRole.admin),
                    ),
                  );
                },
                child: const Text("Admin"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => const PetHomePage(role: UserRole.customer),
                    ),
                  );
                },
                child: const Text("Customer"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------- HOME PAGE --------------------
class PetHomePage extends StatelessWidget {
  final UserRole role;

  const PetHomePage({super.key, required this.role});

  bool get isAdmin => role == UserRole.admin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: 300,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFB9C57D), Color(0xFF9FB66D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(80),
                ),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(
                            Icons.notifications_none,
                            color: Colors.white,
                          ),
                          IconButton(
                            icon: const Icon(Icons.logout, color: Colors.white),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RoleSelectionPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Halo",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      Text(
                        isAdmin ? "Admin!" : "Pingu!",
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: Text('🐶', style: TextStyle(fontSize: 50)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (!isAdmin)
                        Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.brown[800],
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AddPetProfilePage(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Add Pet Profile",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GridView.count(
                            crossAxisCount: 3,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            children: [
                              _serviceCard(
                                context,
                                "Bathing",
                                Icons.bathtub,
                                const Color(0xFFD9D1BD),
                              ),
                              _serviceCard(
                                context,
                                "Nail\nTrimmer",
                                Icons.cut,
                                const Color(0xFFD6A55D),
                              ),
                              _serviceCard(
                                context,
                                "Hair\ncut",
                                Icons.content_cut,
                                const Color(0xFF78824B),
                              ),
                              _placeholderCard('🐕'),
                              _placeholderCard('🐈'),
                              _placeholderCard('🦜'),
                            ],
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            "Live Cameras",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _cameraCard(context, "Cage Camera", "📷"),
                                const SizedBox(width: 10),
                                _cameraCard(context, "Playground 1", "🏞️"),
                                const SizedBox(width: 10),
                                _cameraCard(context, "Playground 2", "🏕️"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _serviceCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => CategoryPage(title: title, emoji: '🐾', bgColor: color),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _placeholderCard(String emoji) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          "$emoji\nComing Soon",
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _cameraCard(BuildContext context, String title, String emoji) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CameraViewPage(cameraTitle: title)),
        );
      },
      child: SizedBox(
        width: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 90,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 40)),
              ),
            ),
            const SizedBox(height: 5),
            Text(title, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

// -------------------- CATEGORY PAGE --------------------
class CategoryPage extends StatelessWidget {
  final String title;
  final String emoji;
  final Color bgColor;

  const CategoryPage({
    super.key,
    required this.title,
    required this.emoji,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> history = [
      {"service": "Bathing", "date": "2 Januari 2024"},
      {"service": "Bathing", "date": "5 Januari 2024"},
      {"service": "Bathing", "date": "10 Januari 2024"},
      {"service": "Bathing", "date": "15 Januari 2024"},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            height: 280,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(80),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _profileCard(),
                    const SizedBox(height: 30),
                    const Text(
                      "History",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Dynamic History List
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final entry = history[index];
                        return _historyEntry(entry["service"]!, entry["date"]!);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileCard() {
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
              children: const [
                Text(
                  "Rafa",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text("Bathing", style: TextStyle(color: Colors.black54)),
                Text(
                  "Alamat toko",
                  style: TextStyle(color: Colors.black45, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            children: const [
              Text(
                "30",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text("March", style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _historyEntry(String service, String date) {
    return Column(
      children: [
        ListTile(
          title: Text(
            service,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(date),
        ),
        const Divider(),
      ],
    );
  }
}

// -------------------- ADD PET PROFILE PAGE --------------------
class AddPetProfilePage extends StatelessWidget {
  const AddPetProfilePage({super.key});

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
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),

                  const SizedBox(height: 10),

                  // Title
                  const Text(
                    "Add Pet Profile",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  // Dog emoji
                  Align(
                    alignment: Alignment.topRight,
                    child: Text('🐶', style: const TextStyle(fontSize: 100)),
                  ),

                  const SizedBox(height: 30),

                  // Name input
                  const Text(
                    "Pet Name",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "e.g. Bruno",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
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
                    decoration: InputDecoration(
                      hintText: "e.g. Golden Retriever",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
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
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "e.g. 3",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Add Now button
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown[800],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder:
                              (ctx) => AlertDialog(
                                content: const Text(
                                  "SUCCESS",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop(); // close dialog
                                      Navigator.of(context).pop(); // go home
                                    },
                                    child: const Text("OK"),
                                  ),
                                ],
                              ),
                        );
                      },
                      child: const Text(
                        "ADD NOW",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//Widget _chip(String label) {
//  return Padding(
//    padding: const EdgeInsets.symmetric(horizontal: 6),
//    child: Chip(
//      label: Text(label, style: const TextStyle(color: Colors.white)),
//      backgroundColor: const Color(0xFF9A7AFF)
//   ),
//  );
//}
