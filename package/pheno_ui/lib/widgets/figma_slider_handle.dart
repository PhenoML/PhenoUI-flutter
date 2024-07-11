import 'package:flutter/widgets.dart';

import 'figma_frame.dart';
import 'figma_slider.dart';

class FigmaSliderHandle extends FigmaFrame {
  const FigmaSliderHandle({
    required super.model,
    super.key
  });

  static FigmaSliderHandle fromJson(Map<String, dynamic> json) {
    return FigmaFrame.fromJson(json, FigmaSliderHandle.new);
  }

  @override
  Widget buildFigmaNode(BuildContext context) {
    FigmaSliderInterface? slider = FigmaSlider.maybeOf(context);

    if (slider != null) {
      return Transform(
        transform: slider.handleTransform,
        child: super.buildFigmaNode(context),
      );
    }

    return super.buildFigmaNode(context);
  }
}