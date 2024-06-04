import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class BackgroundBlur extends SingleChildRenderObjectWidget {
  final double radius;

  const BackgroundBlur({
    required this.radius,
    super.child,
    super.key,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    final renderObject = RenderBackgroundBlur();
    updateRenderObject(context, renderObject);
    return renderObject;
  }

  @override
  void updateRenderObject(BuildContext context, RenderBackgroundBlur renderObject) {
    renderObject.radius = radius;
  }
}

class RenderBackgroundBlur extends RenderProxyBox {
  late double radius;

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
      ..color = const Color(0xFFFFFFFF)
      ..blendMode = BlendMode.dstIn
      ..imageFilter = ImageFilter.compose(
        inner: forceWhite,
        outer: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
      )
    ;

    BackdropFilterLayer backdropFilterLayer = BackdropFilterLayer(
      filter: ImageFilter.blur(sigmaX: radius * 0.5, sigmaY: radius * 0.5),
    );

    // clip the image to optimize multiple backdrop filters on screen:
    // https://github.com/flutter/flutter/issues/126353
    context.pushClipRect(true, offset, Offset.zero & size, (context, offset) {
      // push the backdrop filter
      context.pushLayer(backdropFilterLayer, (context, offset) {
        // mask the effect based on the children being rendered
        context.canvas.saveLayer(bounds, maskPaint);
        context.paintChild(child!, offset);
        context.canvas.restore();
      }, offset);
    });

    // paint the original child on top of the effect
    // NOTE: The children must be translucent for the effect to be visible
    // context.paintChild(child!, offset);
  }
}