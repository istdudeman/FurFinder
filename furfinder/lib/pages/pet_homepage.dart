import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_role.dart';
import '../pages/add_pet_profile_page.dart';
import '../pages/camera_view_page.dart';
import '../pages/category_pages.dart';
import '../pages/login_page.dart';
import '../widgets/camera_card.dart';
import '../widgets/placeholder_card.dart';
import '../widgets/service_card.dart';
import '../pages/activity_log_page.dart';
import 'transactions_page.dart';
import 'settings_page.dart';
import '../pages/camera_playground.dart';
import 'customer_profile_page.dart'; // Import the new customer profile page

class PetHomePage extends StatefulWidget {
  final UserRole role;

  const PetHomePage({super.key, required this.role});

  @override
  State<PetHomePage> createState() => _PetHomePageState();
}

class _PetHomePageState extends State<PetHomePage> {
  final supabase = Supabase.instance.client;
  String userName = '';
  String userId = '';
  String? currentPetID;
  bool isLoading = true;

  bool get isAdmin => widget.role == UserRole.admin;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        return;
      }

      userId = user.id;
      debugPrint('Fetching user data for userId: $userId');

      // Ambil data nama user dari tabel `users`
      // This query assumes 'id' in 'users' is unique, which it should be as a primary key.
      final userRes = await supabase
          .from('users')
          .select('name')
          .eq('id', userId)
          .maybeSingle(); // Kept maybeSingle() as 'id' should be unique.

      // Ambil data hewan dari tabel `pets`
      // Using .limit(1) to get only one pet's ID, as the UI expects a single currentPetID.
      // This addresses the "multiple rows returned" error when a user has multiple pets.
      final petRes = await supabase
          .from('pets')
          .select('animal_id')
          .eq('user_id', userId)
          .limit(1) // Limit to 1 pet, assuming the UI focuses on one pet at a time
          .maybeSingle();

      if (mounted) {
        setState(() {
          userName = userRes?['name'] ?? 'User';
          currentPetID = petRes?['animal_id'];
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching data in PetHomePage: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load home page data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
                      // Header Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.shopping_basket_outlined,
                                  color: Colors.white,
                                ),
                                onPressed:
                                    currentPetID == null
                                        ? () => showDialog(
                                          context: context,
                                          builder:
                                              (_) => AlertDialog(
                                                title: const Text(
                                                  'Isi Profil Hewan',
                                                ),
                                                content: const Text(
                                                  'Silakan isi data hewan terlebih dahulu.',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed:
                                                        () => Navigator.pop(
                                                          context,
                                                        ),
                                                    child: const Text('OK'),
                                                  ),
                                                ],
                                              ),
                                        )
                                        : () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => TransactionPage(
                                                    petID: currentPetID!,
                                                  ),
                                            ),
                                          );
                                        },
                                tooltip: 'New Booking',
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.notifications_none,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ActivityLogPage(),
                                    ),
                                  );
                                },
                              ),
                               if (!isAdmin) // Only show for customers
                                IconButton(
                                  icon: const Icon(
                                    Icons.person, // User icon
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const CustomerProfilePage(),
                                      ),
                                    );
                                  },
                                  tooltip: 'My Profile',
                                ),
                              IconButton(
                                icon: const Icon(
                                  Icons.settings,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SettingsPage(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.logout, color: Colors.white),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginPage(),
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
                        isAdmin ? "Admin!" : "$userName!",
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
                      padding: const EdgeInsets.all(20),
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
                                role: widget.role,
                                petID: currentPetID ?? '',
                                serviceID:
                                    "1b7790d8-987d-41f9-bb53-5a078c8be1de",
                              ),
                              ServiceCard(
                                title: "Nail\nTrimmer",
                                icon: Icons.cut,
                                color: const Color(0xFFD6A55D),
                                role: widget.role,
                                petID: currentPetID ?? '',
                                serviceID:
                                    "e2c3b5a1-4f89-4b1a-9c2e-7d6f5c8a4b3d",
                              ),
                              ServiceCard(
                                title: "Hair\ncut",
                                icon: Icons.content_cut,
                                color: const Color(0xFF78824B),
                                role: widget.role,
                                petID: currentPetID ?? '',
                                serviceID:
                                    "f4a5c6b2-8e9d-4f7c-a1b3-6d5e4f3a2b1c",
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
                                  emoji: "�",
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => CameraViewPage(
                                              cameraTitle: "Cage Camera",
                                              userId: userId,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 10),
                                CameraCard(
                                  title: "Playground 1",
                                  emoji: "🏞️",
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => CameraPlaygroundPage(
                                              cameraTitle: "Playground 1",
                                            ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 10),
                                CameraCard(
                                  title: "Playground 2",
                                  emoji: "🏕️",
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => CameraViewPage(
                                              cameraTitle: "Playground 2",
                                              userId: userId,
                                            ),
                                      ),
                                    );
                                  },
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