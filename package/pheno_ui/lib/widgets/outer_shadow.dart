import 'dart:math';
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class OuterShadow extends SingleChildRenderObjectWidget {
  final List<BoxShadow> shadows;
  
  const OuterShadow({
    this.shadows = const <BoxShadow>[],
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
  late List<BoxShadow> shadows;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;

    final bounds = offset & size;

    for (final shadow in shadows) {
      final scale = Size(
        1.0 + (shadow.spreadRadius * 0.5) / (bounds.width),
        1.0 + (shadow.spreadRadius * 0.5) / (bounds.height),
      );
      final anchor = Offset(
        bounds.left + bounds.width * 0.5,
        bounds.top + bounds.height * 0.5,
      );
      final anchorMatrix = Matrix4.identity()..translate(-anchor.dx, -anchor.dy);
      final scaleMatrix = Matrix4.identity()..scale(scale.width, scale.height);
      final centerMatrix = Matrix4.identity()..translate(anchor.dx, anchor.dy);
      final matrix = centerMatrix * scaleMatrix * anchorMatrix;
      final shadowBounds = bounds.inflate(shadow.spreadRadius * 0.5 + shadow.blurSigma + max(shadow.offset.dx, shadow.offset.dy));
      final shadowPaint = Paint()
        ..colorFilter = ColorFilter.mode(shadow.color, BlendMode.srcIn)
        ..imageFilter = ImageFilter.compose(
          outer: ImageFilter.blur(sigmaX: shadow.blurSigma * 0.5, sigmaY: shadow.blurSigma * 0.5, tileMode: TileMode.decal),
          inner: ImageFilter.matrix(matrix.storage),
        )
      ;
      context.canvas
        ..saveLayer(shadowBounds, shadowPaint)
        ..translate(shadow.offset.dx, shadow.offset.dy)
      ;
      context.paintChild(child!, offset);
      context.canvas.restore();
    }

    context.canvas.saveLayer(bounds, Paint());
    context.paintChild(child!, offset);
    context.canvas.restore();
  }
}
