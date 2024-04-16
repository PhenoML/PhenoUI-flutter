import 'package:flutter/widgets.dart';
import 'package:pheno_ui/widgets/figma_frame.dart';

class FigmaSafeArea extends FigmaFrame {
  const FigmaSafeArea({
    required super.childrenContainer,
    required super.model,
    super.key
  });

  static FigmaFrame fromJson(Map<String, dynamic> json) {
    return FigmaFrame.fromJson(json, FigmaSafeArea.new);
  }

  @override
  Widget buildFigmaNode(BuildContext context) {
    return SafeArea(
      child: super.buildFigmaNode(context),
    );
  }
}