import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'dict.dart';

class Intro extends StatefulWidget {
  const Intro(this.l, {Key? key}) : super(key: key);
  final String l;

  @override
  IntroState createState() => IntroState();
}

class IntroState extends State<Intro> with TickerProviderStateMixin {
  int page = 0;
  late final AnimationController _controller =
      AnimationController(duration: const Duration(seconds: 15), vsync: this)
        ..repeat();
  late Animation _animation;

  @override
  void initState() {
    super.initState();
    _animation = Tween<double>(begin: 0, end: 360).animate(_controller)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (page != 0) _controller.stop();
    switch (page) {
      default:
        return Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: FractionallySizedBox(
              widthFactor: 0.8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.rotate(
                    angle: _animation.value * math.pi / 180,
                    child: const SizedBox(
                      child: Image(image: AssetImage('assets/logo.png')),
                      width: 200,
                      height: 200,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 35, bottom: 15),
                    child: Text(
                      dict[widget.l]!["welcome"]!,
                      textScaleFactor: 2.5,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 35),
                    child: Text(
                      dict[widget.l]!["welDesc"]!,
                      textScaleFactor: 1.5,
                      textAlign: TextAlign.justify,
                      style: const TextStyle(
                        color: Colors.blue,
                        height: 1.5,
                      ),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: 1,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsets>(
                            const EdgeInsets.symmetric(vertical: 10)),
                      ),
                      child: Text(
                        dict[widget.l]!["next"]!,
                        textScaleFactor: 2,
                      ),
                      onPressed: () => setState(() => page++),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
}
