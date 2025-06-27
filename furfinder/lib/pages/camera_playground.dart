import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';

class CameraPlaygroundPage extends StatelessWidget {
  final String cameraTitle;

  const CameraPlaygroundPage({
    super.key,
    required this.cameraTitle,
  });

  @override
  Widget build(BuildContext context) {
    const streamUrl = 'http://192.168.18.147/stream';

    return Scaffold(
      appBar: AppBar(title: Text(cameraTitle)),
      body: Center(
        child: Mjpeg(
          isLive: true,
          stream: streamUrl,
          error: (context, error, stack) {
            return const Text('Error loading playground stream');
          },
        ),
      ),
    );
  }
}
