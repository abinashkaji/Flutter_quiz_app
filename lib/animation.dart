import 'package:flutter/material.dart';

class FlipAnimation extends StatefulWidget {
  final bool showAnswer;
  final String question;
  final String answer;

  const FlipAnimation({
    Key? key,
    required this.showAnswer,
    required this.question,
    required this.answer,
  }) : super(key: key);

  @override
  _FlipAnimationState createState() => _FlipAnimationState();
}

class _FlipAnimationState extends State<FlipAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = Tween<double>(begin: 0.0, end: .5).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant FlipAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showAnswer != widget.showAnswer) {
      if (widget.showAnswer) {
        _controller.reverse(from: .5);
      } else {
        _controller.reverse(from: 1.5);
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(_animation.value * 3.141),
          alignment: Alignment.center,
          child: child,
        );
      },
      child: widget.showAnswer
          ? Text(
              widget.answer,
              style: const TextStyle(
                fontSize: 30.0,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
              selectionColor: Colors.black,
            )
          : Text(
              widget.question,
              style: const TextStyle(
                fontSize: 30.0,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
              selectionColor: Colors.black,
            ),
    );
  }
}
