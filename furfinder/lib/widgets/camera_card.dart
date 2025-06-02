import 'package:flutter/material.dart';
// The import for CameraViewPage is no longer strictly needed here
// if the navigation is handled by the onTap callback provided by the parent.
// iTS OKAY TO KEEP IT HERE. JUST FOR CLARITY ON HOW TO PARSE THINGS BY PARENT AND CHILD.
// import 'package:fur_finder/pages/camera_view_page.dart';

class CameraCard extends StatelessWidget {
  final String title;
  final String emoji;
  final VoidCallback onTap; 

  const CameraCard({
    super.key,
    required this.title,
    required this.emoji,
    required this.onTap, 
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // <-- USE THE 'onTap' PARAMETER HERE
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