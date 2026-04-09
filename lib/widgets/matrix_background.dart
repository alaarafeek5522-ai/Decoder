import 'package:flutter/material.dart';
import 'dart:math';

class MatrixBackground extends StatefulWidget {
  final Widget child;
  const MatrixBackground({super.key, required this.child});

  @override
  State<MatrixBackground> createState() => _MatrixBackgroundState();
}

class _MatrixBackgroundState extends State<MatrixBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  List<MatrixChar> _chars = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    )..addListener(() {
      setState(() {
        _updateChars();
      });
    });
    _controller.repeat();
    _initChars();
  }

  void _initChars() {
    const String chars = '01アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン';
    for (int i = 0; i < 100; i++) {
      _chars.add(MatrixChar(
        char: chars[_random.nextInt(chars.length)],
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        speed: 0.005 + _random.nextDouble() * 0.01,
        opacity: 0.3 + _random.nextDouble() * 0.7,
      ));
    }
  }

  void _updateChars() {
    for (var char in _chars) {
      char.y += char.speed;
      if (char.y > 1) {
        char.y = 0;
        const String chars = '01アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン';
        char.char = chars[_random.nextInt(chars.length)];
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0a0a0a), Color(0xFF001a00)],
        ),
      ),
      child: Stack(
        children: [
          // Matrix effect
          CustomPaint(
            painter: MatrixPainter(chars: _chars),
            size: Size.infinite,
          ),
          // Glowing overlay
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                ],
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class MatrixChar {
  String char;
  double x;
  double y;
  double speed;
  double opacity;
  
  MatrixChar({
    required this.char,
    required this.x,
    required this.y,
    required this.speed,
    required this.opacity,
  });
}

class MatrixPainter extends CustomPainter {
  final List<MatrixChar> chars;
  
  MatrixPainter({required this.chars});
  
  @override
  void paint(Canvas canvas, Size size) {
    final textStyle = TextStyle(
      color: Colors.green,
      fontSize: 14,
      fontFamily: 'monospace',
    );
    
    for (var char in chars) {
      final textSpan = TextSpan(
        text: char.char,
        style: textStyle.copyWith(
          color: Colors.green.withOpacity(char.opacity),
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(char.x * size.width, char.y * size.height),
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
