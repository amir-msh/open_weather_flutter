import 'package:flutter/material.dart';

class SidesFader extends StatelessWidget {
  final Widget child;
  const SidesFader({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: const [0, 0.05, 0.95, 1],
          colors: <Color>[
            Colors.black.withAlpha(0),
            Colors.black.withAlpha(255),
            Colors.black.withAlpha(255),
            Colors.black.withAlpha(0),
          ],
        ).createShader(bounds);
      },
      child: child,
    );
  }
}
