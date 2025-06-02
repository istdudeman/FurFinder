import 'package:flutter/material.dart';
import '../models/user_role.dart';
import '../pages/add_pet_profile_page.dart';
import '../pages/camera_view_page.dart';
import '../pages/category_pages.dart';
import '../pages/role_selection.dart';
import '../widgets/camera_card.dart';
import '../widgets/placeholder_card.dart';
import '../widgets/service_card.dart';
import '../pages/activity_log_page.dart'; // <-- IMPORT THIS

class PetHomePage extends StatelessWidget {
  final UserRole role;

  final String currentPetID = "pingu_001";

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
                          // --- MODIFICATION STARTS HERE ---
                          IconButton( // Changed from Icon to IconButton
                            icon: const Icon(
                              Icons.notifications_none,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ActivityLogPage()),
                              );
                            },
                            tooltip: 'Activity Log', // Optional: for accessibility
                          ),
                          // --- MODIFICATION ENDS HERE ---
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
                              ServiceCard(
                                title: "Bathing",
                                icon: Icons.bathtub,
                                color: const Color(0xFFD9D1BD),
                                role: role,
                                petID: currentPetID,
                              ),
                              ServiceCard(
                                title: "Nail\nTrimmer",
                                icon: Icons.cut,
                                color: const Color(0xFFD6A55D),
                                role: role,
                                petID: currentPetID,
                              ),
                              ServiceCard(
                                title: "Hair\ncut",
                                icon: Icons.content_cut,
                                color: const Color(0xFF78824B),
                                role: role,
                                petID: currentPetID,
                              ),
                              const PlaceholderCard(emoji: '🐕'),
                              const PlaceholderCard(emoji: '🐈'),
                              const PlaceholderCard(emoji: '🦜'),
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
                                CameraCard(
                                  title: "Cage Camera",
                                  emoji: "📷",
                                  onTap: () {
                                     Navigator.push(context, MaterialPageRoute(builder: (_) => const CameraViewPage(cameraTitle: "Cage Camera")));
                                  }
                                ),
                                const SizedBox(width: 10),
                                CameraCard(
                                  title: "Playground 1",
                                  emoji: "🏞️",
                                  onTap: () {
                                     Navigator.push(context, MaterialPageRoute(builder: (_) => const CameraViewPage(cameraTitle: "Playground 1")));
                                  }
                                ),
                                const SizedBox(width: 10),
                                CameraCard(
                                  title: "Playground 2",
                                  emoji: "🏕️",
                                  onTap: () {
                                     Navigator.push(context, MaterialPageRoute(builder: (_) => const CameraViewPage(cameraTitle: "Playground 2")));
                                  }
                                ),
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
}