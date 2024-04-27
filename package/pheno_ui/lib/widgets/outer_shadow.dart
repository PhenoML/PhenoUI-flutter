import 'dart:math';
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class OuterShadow extends SingleChildRenderObjectWidget {
  const OuterShadow({
    Key? key,
    this.shadows = const <BoxShadow>[],
    Widget? child,
  }) : super(key: key, child: child);

  final List<BoxShadow> shadows;

  @override
  RenderObject createRenderObject(BuildContext context) {
    final renderObject = RenderInnerShadow();
    updateRenderObject(context, renderObject);
    return renderObject;
  }

  @override
  void updateRenderObject(BuildContext context, RenderInnerShadow renderObject) {
    renderObject.shadows = shadows;
  }
}

class RenderInnerShadow extends RenderProxyBox {
  late List<BoxShadow> shadows;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;
    final bounds = offset & size;

    for (final shadow in shadows) {
      final scale = Size(
        1.0 + shadow.spreadRadius / (bounds.width * 0.5),
        1.0 + shadow.spreadRadius / (bounds.height * 0.5),
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
        ..blendMode = BlendMode.srcATop
        ..colorFilter = ColorFilter.mode(shadow.color, BlendMode.srcIn)
        ..imageFilter = ImageFilter.compose(
          outer: ImageFilter.blur(sigmaX: shadow.blurSigma, sigmaY: shadow.blurSigma, tileMode: TileMode.decal),
          // outer: ImageFilter.erode(radiusX: shadow.spreadRadius, radiusY: shadow.spreadRadius),
          inner: ImageFilter.matrix(matrix.storage),
        );
      // ..imageFilter = ImageFilter.matrix(matrix.storage);
      context.canvas
        ..saveLayer(shadowBounds, shadowPaint)
        ..translate(shadow.offset.dx, shadow.offset.dy);
      context.paintChild(child!, offset);
      context.canvas.restore();
    }

    context.canvas.saveLayer(bounds, Paint());
    context.canvas.scale(1.0, 1.0);
    // context.canvas.translate(100.0, 100.0);
    context.paintChild(child!, offset);

    context.canvas.restore();
  }
}