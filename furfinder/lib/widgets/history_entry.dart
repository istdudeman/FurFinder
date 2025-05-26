import 'package:flutter/material.dart';

class HistoryEntry extends StatelessWidget {
  final String service;
  final String date;

  const HistoryEntry({super.key, required this.service, required this.date});

  @override
  Widget build(BuildContext context) {
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