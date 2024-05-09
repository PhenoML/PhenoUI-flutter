import 'package:flutter/widgets.dart';
import '../models/figma_frame_model.dart';
import 'figma_frame.dart';

class FigmaSafeArea extends FigmaFrame {
  const FigmaSafeArea({
    required super.model,
    super.key
  });

  static FigmaSafeArea fromJson(Map<String, dynamic> json) {
    return FigmaFrame.fromJson(json, FigmaSafeArea.new, FigmaFrameModel.fromJson);
  }

  @override
  Widget buildFigmaNode(BuildContext context) {
    Matrix4 bottomInset = Matrix4.identity();
    bottomInset.translate(0.0, -MediaQuery.of(context).viewInsets.bottom * 0.7, 0.0);

    return Transform(
      transform: bottomInset,
      child: SafeArea(
        maintainBottomViewPadding: true,
        child: super.buildFigmaNode(context),
      ),
    );
  }
}