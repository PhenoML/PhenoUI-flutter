import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class InnerShadow extends SingleChildRenderObjectWidget {
  const InnerShadow({
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

    context.canvas.saveLayer(bounds, Paint());
    context.paintChild(child!, offset);

    for (final shadow in shadows) {
      final scale = Size(
        1.0 - shadow.spreadRadius / (bounds.width * 0.5),
        1.0 - shadow.spreadRadius / (bounds.height * 0.5),
      );
      final anchor = Offset(
        bounds.left + bounds.width * 0.5,
        bounds.top + bounds.height * 0.5,
      );
      final anchorMatrix = Matrix4.identity()..translate(-anchor.dx, -anchor.dy);
      final scaleMatrix = Matrix4.identity()..scale(scale.width, scale.height);
      final centerMatrix = Matrix4.identity()..translate(anchor.dx, anchor.dy);
      final matrix = centerMatrix * scaleMatrix * anchorMatrix;
      final shadowPaint = Paint()
        ..blendMode = BlendMode.srcATop
        ..colorFilter = ColorFilter.mode(shadow.color, BlendMode.srcOut)
        ..imageFilter = ImageFilter.compose(
          outer: ImageFilter.blur(sigmaX: shadow.blurSigma, sigmaY: shadow.blurSigma),
          // outer: ImageFilter.erode(radiusX: shadow.spreadRadius, radiusY: shadow.spreadRadius),
          inner: ImageFilter.matrix(matrix.storage),
        );
      // ..imageFilter = ImageFilter.matrix(matrix.storage);
      context.canvas
        ..saveLayer(bounds, shadowPaint)
        ..translate(shadow.offset.dx, shadow.offset.dy);
      context.paintChild(child!, offset);
      context.canvas.restore();
    }

    context.canvas.restore();
  }
}