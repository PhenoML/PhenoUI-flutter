import 'package:flutter/widgets.dart';

import 'figma_frame.dart';

class FigmaKeepAspectRatio extends FigmaFrame {
  const FigmaKeepAspectRatio({
    required super.model,
    super.key
  });

  static FigmaKeepAspectRatio fromJson(Map<String, dynamic> json) {
    return FigmaFrame.fromJson(json, FigmaKeepAspectRatio.new);
  }

  @override
  Widget buildFigmaNode(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: AspectRatio(
          aspectRatio: dimensions!.width / dimensions!.height,
          child: super.buildFigmaNode(context),
      ),
    );
  }
}