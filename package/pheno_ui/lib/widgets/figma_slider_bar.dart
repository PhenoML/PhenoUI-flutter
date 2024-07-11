import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'figma_frame.dart';
import 'figma_slider.dart';

class FigmaSliderBar extends FigmaFrame {
  const FigmaSliderBar({
    required super.model,
    super.key
  });

  static FigmaSliderBar fromJson(Map<String, dynamic> json) {
    return FigmaFrame.fromJson(json, FigmaSliderBar.new);
  }

  @override
  Widget buildFigmaNode(BuildContext context) {
    FigmaSliderInterface? slider = FigmaSlider.maybeOf(context);

    if (slider != null) {
      return _LayoutObserver(
        onOffsetChanged: (Offset offset) {
          slider.setHorizontalBarOffset(offset.dx);
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            slider.setBarLength(constraints.maxWidth);
            return Transform(
              transform: slider.barTransform,
              child: super.buildFigmaNode(context),
            );
          }
        ),
      );
    }

    return super.buildFigmaNode(context);
  }
}

class _LayoutObserver extends SingleChildRenderObjectWidget {
  final void Function(Size)? onSizeChanged;
  final void Function(Offset)? onOffsetChanged;

  const _LayoutObserver({
    this.onSizeChanged,
    this.onOffsetChanged,
    required super.child,
    super.key
  });

  @override
  RenderObject createRenderObject(BuildContext context) =>
    _LayoutObserverRenderObject(
      onSizeChanged: onSizeChanged,
      onOffsetChanged: onOffsetChanged,
    );
}

class _LayoutObserverRenderObject extends RenderProxyBox {
  Size? _oldSize;
  Offset? _oldOffset;

  final void Function(Size)? onSizeChanged;
  final void Function(Offset)? onOffsetChanged;

  _LayoutObserverRenderObject({
    required this.onSizeChanged,
    required this.onOffsetChanged,
    RenderBox? child,
  }) : super(child);

  @override
  void performLayout() {
    super.performLayout();
    if (onSizeChanged != null && _oldSize != size) {
      onSizeChanged!(size);
      _oldSize = size;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    if (onOffsetChanged != null && _oldOffset != offset) {
      onOffsetChanged!(offset);
      _oldOffset = offset;
    }
  }
}
