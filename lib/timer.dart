import 'dart:async';
import 'package:flutter/material.dart';

class FloatingTimer extends StatefulWidget {
  @override
  _FloatingTimerState createState() => _FloatingTimerState();
}

class _FloatingTimerState extends State<FloatingTimer> {
  late Timer _timer;
  int _secondsElapsed = 0;

  @override
  void initState() {
    super.initState();
    // Start the timer when the widget is initialized
    _timer = Timer.periodic(const Duration(seconds:1 ), _updateTimer);
  }

  @override
  void dispose() {
    // Dispose the timer when the widget is disposed
    _timer.cancel();
    super.dispose();
  }

  void _updateTimer(Timer timer) {
    setState(() {
      _secondsElapsed+=1;
    });
  }

  String _formatDuration(Duration duration) {
    // Format the duration as HH:MM:SS
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours.remainder(24));
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String sec = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$sec';
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      right: 0,
      child: Container(
        width: 100,
        height: 20,
//        color: Color(0xFFF86E04),// Color.fromARGB(255, 206, 102, 41),
        child: Stack(alignment: Alignment.center, 
          children: [Text(
            _formatDuration(Duration(seconds: _secondsElapsed)),
            style: const TextStyle(color: Color(0xFFF86E04),fontSize: 18, ),
          ),]
        ),
      ),
    );
  }
}
