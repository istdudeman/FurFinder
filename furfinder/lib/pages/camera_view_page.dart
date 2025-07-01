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
        String? rawUrl = result['url'];
        if (rawUrl != null) {
          // Use a regex to find the actual URL starting with http or https.
          // This is more robust against invisible characters or extra newlines
          // that might precede the actual URL string.
          RegExp urlRegex = RegExp(r'(https?://\S+)');
          Match? match = urlRegex.firstMatch(rawUrl);
          if (match != null) {
            streamUrl = match.group(0); // Get the matched URL string
          } else {
            // If regex doesn't find a valid URL, set streamUrl to null
            streamUrl = null;
            debugPrint("⚠️ Regex could not find a valid URL in: $rawUrl");
          }
        } else {
          streamUrl = null;
        }
        
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
                        // The streamUrl should now be clean, but adding trim() here again
                        // as a final safeguard doesn't hurt.
                        stream: streamUrl!.trim(), 
                        error: (context, error, stack) {
                          debugPrint('MJPEG Stream Error: $error');
                          debugPrint('Stack Trace: $stack');
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Error loading stream:',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    error.toString(), // Display the actual error message
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Please ensure the camera is on and your device is on the same network.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
