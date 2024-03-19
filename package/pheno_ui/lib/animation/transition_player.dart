import 'package:flutter/widgets.dart';

class TransitionPlayer extends StatelessWidget {
  final Animation<Map<String, dynamic>> animation;
  final Widget child;

  const TransitionPlayer({
    required this.animation,
    required this.child,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> value = animation.value;
    Size screenSize = MediaQuery.of(context).size;
    Offset anchor = value['anchor'] ?? const Offset(0.5, 0.5);

    final Matrix4 translationM4 = Matrix4.identity();
    final Offset? offset = value['offset'];
    if (offset != null) {
      translationM4.translate(offset.dx * screenSize.width, offset.dy * screenSize.height);
    }

    final Matrix4 rotationM4 = Matrix4.identity();
    final double? rotation = value['rotation'];
    if (rotation != null) {
      final Offset rotationAnchor = value['rotationAnchor'] ?? anchor;
      rotationM4.translate(screenSize.width * rotationAnchor.dx, screenSize.height * rotationAnchor.dy);
      rotationM4.rotateZ(rotation);
      rotationM4.translate(-screenSize.width * rotationAnchor.dx, -screenSize.height * rotationAnchor.dy);
    }

    final Matrix4 scaleM4 = Matrix4.identity();
    final double? scale = value['scale'];
    if (scale != null) {
      final Offset scaleAnchor = value['scaleAnchor'] ?? anchor;
      scaleM4.translate(screenSize.width * scaleAnchor.dx, screenSize.height * scaleAnchor.dy);
      scaleM4.scale(scale);
      scaleM4.translate(-screenSize.width * scaleAnchor.dx, -screenSize.height * scaleAnchor.dy);
    }

    final Matrix4 transform = translationM4 * rotationM4 * scaleM4;

    return Transform(
      transform: transform,
      child: child,
    );
  }

}