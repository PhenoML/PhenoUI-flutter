import 'package:flutter/widgets.dart';
import '../models/figma_frame_model.dart';
import 'figma_frame.dart';

class FigmaSafeArea extends FigmaFrame {
  const FigmaSafeArea({
    required super.childrenContainer,
    required super.model,
    super.key
  });

  static FigmaSafeArea fromJson(Map<String, dynamic> json) {
    return figmaFrameFromJson(json, FigmaSafeArea.new, FigmaFrameModel.fromJson);
  }

  @override
  Widget buildFigmaNode(BuildContext context) {
    return SafeArea(
      child: super.buildFigmaNode(context),
    );
  }
}