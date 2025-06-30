import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import '../api/camera_api.dart'; // Import file API baru

class CameraViewPage extends StatefulWidget {
  final String cameraTitle;
  final String userId;

  const CameraViewPage({
    super.key,
    required this.cameraTitle,
    required this.userId,
  });

  @override
  State<CameraViewPage> createState() => _CameraViewPageState();
}

class _CameraViewPageState extends State<CameraViewPage> {
  String? streamUrl;
  String? petName;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchStreamInfo();
  }

  Future<void> fetchStreamInfo() async {
    final result = await fetchUserCameraStream(widget.userId); // result: Map<String, String>?

    if (result != null) {
      setState(() {
        streamUrl = result['url'];
        petName = result['name'];
        isLoading = false;
      });
      debugPrint("✅ Stream URL: $streamUrl untuk $petName");
    } else {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.cameraTitle)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError || streamUrl == null
              ? Center(
                  child: Text('Gagal memuat stream kamera.\nURL: $streamUrl'),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    if (petName != null)
                      Text(
                        '🎥 Kamera aktif untuk: $petName',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Mjpeg(
                        isLive: true,
                        stream: streamUrl!,
                        error: (context, error, stack) {
                          return const Text('Error loading stream');
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
