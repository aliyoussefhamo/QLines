import 'package:flutter/material.dart';

class RealtimeStatusBadge extends StatelessWidget {
  const RealtimeStatusBadge({required this.isConnected, super.key});

  final bool isConnected;

  @override
  Widget build(BuildContext context) {
    final color = isConnected ? Colors.green : Colors.red;
    return Tooltip(
      message: isConnected ? 'متصل لحظياً' : 'الاتصال اللحظي منقطع',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              isConnected ? 'متصل' : 'منقطع',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ),
    );
  }
}
