  import 'package:flutter/material.dart';
  import 'package:http/http.dart' as http;
  import 'dart:convert';
  import 'package:flutter_mjpeg/flutter_mjpeg.dart';

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
      try {
        final response = await http.get(
          Uri.parse('https://c34b-182-253-50-98.ngrok-free.app/api/camera/${widget.petID}'),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            streamUrl = data['url'];
            isLoading = false;
          });
        } else {
          throw Exception('Failed to load camera data');
        }
        debugPrint("✅ Stream URL from backend: $streamUrl");
      } catch (e) {
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
                ? Center(child: Text('Failed to load camera stream, stream URL : $streamUrl'))
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
