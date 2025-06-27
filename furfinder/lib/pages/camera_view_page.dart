import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import '../api/camera_api.dart'; // Import file API baru

class CameraViewPage extends StatefulWidget {
  final String cameraTitle;
  final String petID;

  const CameraViewPage({
    super.key,
    required this.cameraTitle,
    required this.petID,
  });

  @override
  State<CameraViewPage> createState() => _CameraViewPageState();
}

class _CameraViewPageState extends State<CameraViewPage> {
  String? streamUrl;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchStreamUrl();
  }

  Future<void> fetchStreamUrl() async {
    final url = await fetchCameraStreamUrl(widget.petID);

    if (url != null) {
      setState(() {
        streamUrl = url;
        isLoading = false;
      });
      debugPrint("✅ Stream URL: $streamUrl");
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
              ? Center(child: Text('Failed to load camera stream.\nURL: $streamUrl'))
              : Center(
                  child: Mjpeg(
                    isLive: true,
                    stream: streamUrl!,
                    error: (context, error, stack) {
                      return const Text('Error loading stream');
                    },
                  ),
                ),
    );
  }
}
