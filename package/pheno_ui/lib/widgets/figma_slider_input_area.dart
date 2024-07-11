import 'package:flutter/widgets.dart';

import 'figma_frame.dart';
import 'figma_slider.dart';

class FigmaSliderInputArea extends FigmaFrame {
  const FigmaSliderInputArea({
    required super.model,
    super.key
  });

  static FigmaSliderInputArea fromJson(Map<String, dynamic> json) {
    return FigmaFrame.fromJson(json, FigmaSliderInputArea.new);
  }

  @override
  void onMount(BuildContext context) {
    super.onMount(context);
    FigmaSliderInterface? slider = FigmaSlider.maybeOf(context, listen: false);
    if (slider != null) {
      slider.setHasInputArea(true);
    }
  }

  @override
  Widget buildFigmaNode(BuildContext context) {
    FigmaSliderInterface? slider = FigmaSlider.maybeOf(context, listen: false);
    if (slider != null) {
      return GestureDetector(
        onPanDown: slider.onPanDown,
        onPanUpdate: slider.onPanUpdate,
        onPanEnd: slider.onPanEnd,
        onPanCancel: slider.onPanEnd,
        child: super.buildFigmaNode(context),
      );
    }
    return super.buildFigmaNode(context);
  }
}