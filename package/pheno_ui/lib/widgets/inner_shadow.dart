import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class InnerShadow extends SingleChildRenderObjectWidget {
  final List<BoxShadow> shadows;

  const InnerShadow({
    this.shadows = const <BoxShadow>[],
    super.child,
    super.key,
  });

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

    const forceWhite = ColorFilter.matrix(<double>[
      255, 0, 0, 0, 255,
      0, 255, 0, 0, 255,
      0, 0, 255, 0, 255,
      0, 0, 0, 255, 0,
    ]);
    final maskPaint = Paint()
      ..imageFilter = ImageFilter.compose(
        inner: forceWhite,
        outer: ImageFilter.blur(sigmaX: 0.25, sigmaY: 0.25),
      )
    ;
    context.canvas.saveLayer(bounds, Paint());
    context.paintChild(child!, offset);

    for (final shadow in shadows) {
      final scale = Size(
        1.0 - (shadow.spreadRadius) / bounds.width,
        1.0 - (shadow.spreadRadius) / bounds.height,
      );
      final anchor = Offset(
        bounds.left + bounds.width * 0.5,
        bounds.top + bounds.height * 0.5,
      );
      final anchorMatrix = Matrix4.identity()..translate(-anchor.dx, -anchor.dy);
      final scaleMatrix = Matrix4.identity()..scale(scale.width, scale.height);
      final centerMatrix = Matrix4.identity()..translate(anchor.dx, anchor.dy);
      final matrix = centerMatrix * scaleMatrix * anchorMatrix;
      final forceColor = ColorFilter.matrix(<double>[
        0, 0, 0, 0, shadow.color.red.toDouble(),
        0, 0, 0, 0, shadow.color.green.toDouble(),
        0, 0, 0, 0, shadow.color.blue.toDouble(),
        0, 0, shadow.color.opacity, 0, 0,
      ]);
      final blur = ImageFilter.blur(sigmaX: shadow.blurSigma, sigmaY: shadow.blurSigma);
      final spread = ImageFilter.matrix(matrix.storage);

      final shadowPaint = Paint()
        ..blendMode = BlendMode.srcIn
        ..colorFilter = ColorFilter.mode(shadow.color, BlendMode.srcOut)
        ..imageFilter = ImageFilter.compose(
            inner: spread,
            outer: ImageFilter.compose(outer: blur, inner: forceColor)
        )
      ;
      // context.canvas
      //   ..saveLayer(bounds, shadowPaint)
      //   ..translate(shadow.offset.dx, shadow.offset.dy);
      // context.paintChild(child!, offset);
      // context.canvas.restore();

      const forceWhite = ColorFilter.matrix(<double>[
        255, 0, 0, 0, 255,
        0, 255, 0, 0, 255,
        0, 0, 255, 0, 255,
        0, 0, 0, 255, 0,
      ]);
      final maskPaint = Paint()
        ..imageFilter = ImageFilter.compose(
          inner: forceWhite,
          outer: ImageFilter.blur(sigmaX: 0.25, sigmaY: 0.25),
        )
      ;
      context.canvas.saveLayer(bounds, Paint());

        context.canvas.saveLayer(bounds, maskPaint);
        context.paintChild(child!, offset);
        context.canvas.restore();

      context.canvas
        ..saveLayer(bounds, shadowPaint)
        ..translate(shadow.offset.dx, shadow.offset.dy);
      context.paintChild(child!, offset);
      context.canvas.restore();

      context.canvas.restore();
    }

    context.canvas.restore();
  }
}