import 'dart:math';
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class OuterShadowEntry extends BoxShadow {
  final bool showBehindNode;

  const OuterShadowEntry({
    required this.showBehindNode,
    super.color,
    super.offset,
    super.blurRadius,
    super.spreadRadius,
    super.blurStyle,
  });
}

class OuterShadow extends SingleChildRenderObjectWidget {
  final List<OuterShadowEntry> shadows;
  
  const OuterShadow({
    this.shadows = const <OuterShadowEntry>[],
    super.child,
    super.key,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    final renderObject = RenderOuterShadow();
    updateRenderObject(context, renderObject);
    return renderObject;
  }

  @override
  void updateRenderObject(BuildContext context, RenderOuterShadow renderObject) {
    renderObject.shadows = shadows;
  }
}

class RenderOuterShadow extends RenderProxyBox {
  late List<OuterShadowEntry> shadows;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;
    final bounds = offset & size;

    for (final shadow in shadows) {
      final scale = Size(
        1.0 + (shadow.spreadRadius * 2.0) / (bounds.width),
        1.0 + (shadow.spreadRadius * 2.0) / (bounds.height),
      );
      final anchor = Offset(
        bounds.left + bounds.width * 0.5,
        bounds.top + bounds.height * 0.5,
      );
      final anchorMatrix = Matrix4.identity()..translate(-anchor.dx, -anchor.dy);
      final scaleMatrix = Matrix4.identity()..scale(scale.width, scale.height);
      final centerMatrix = Matrix4.identity()..translate(anchor.dx, anchor.dy);
      final matrix = centerMatrix * scaleMatrix * anchorMatrix;
      final shadowBounds = bounds.inflate(shadow.spreadRadius * 2.0 + shadow.blurSigma + max(shadow.offset.dx, shadow.offset.dy));
      final forceColor = ColorFilter.matrix(<double>[
        0, 0, 0, 0, shadow.color.red.toDouble(),
        0, 0, 0, 0, shadow.color.green.toDouble(),
        0, 0, 0, 0, shadow.color.blue.toDouble(),
        0, 0, shadow.color.opacity, 0, 0,
      ]);
      final blur = ImageFilter.blur(sigmaX: shadow.blurSigma * 0.5 / scale.width, sigmaY: shadow.blurSigma * 0.5 / scale.height, tileMode: TileMode.decal);
      final spread = ImageFilter.matrix(matrix.storage);

      final shadowPaint = Paint()
        ..blendMode = BlendMode.srcOut
        ..imageFilter = ImageFilter.compose(
            inner: spread,
            outer: ImageFilter.compose(outer: blur, inner: forceColor)
        )
      ;

      const forceWhite = ColorFilter.matrix(<double>[
        255, 0, 0, 0, 255,
        0, 255, 0, 0, 255,
        0, 0, 255, 0, 255,
        0, 0, 0, 255, 0,
      ]);
      final maskPaint = Paint()
        ..imageFilter = forceWhite
      ;
      context.canvas.saveLayer(shadowBounds, Paint());

      if (!shadow.showBehindNode) {
        context.canvas.saveLayer(shadowBounds, maskPaint);
        context.paintChild(child!, offset);
        context.canvas.restore();
      }

      context.canvas
        ..saveLayer(shadowBounds, shadowPaint)
        ..translate(shadow.offset.dx, shadow.offset.dy);
      context.paintChild(child!, offset);
      context.canvas.restore();

      context.canvas.restore();
    }

    // context.canvas.saveLayer(bounds, Paint());
    // context.paintChild(child!, offset);
    // context.canvas.restore();
  }
}
