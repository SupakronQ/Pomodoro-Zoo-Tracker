import 'package:flutter/material.dart';

class TimerCircle extends StatelessWidget {
  final double progress;
  final String formattedTime;
  final bool isCompleted;

  const TimerCircle({
    Key? key,
    required this.progress,
    required this.formattedTime,
    required this.isCompleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 12,
              backgroundColor: Colors.brown.shade100,
              color: isCompleted ? Colors.green : Colors.deepOrange,
            ),
          ),
          Text(
            formattedTime,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
        ],
      ),
    );
  }
}
