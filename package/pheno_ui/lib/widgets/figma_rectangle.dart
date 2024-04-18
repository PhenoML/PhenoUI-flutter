import 'package:flutter/widgets.dart';

import '../tools/figma_enum.dart';
import '../models/figma_simple_style_model.dart';
import 'stateless_figma_node.dart';

class FigmaRectangle extends StatelessFigmaNode<FigmaSimpleStyleModel> {
  const FigmaRectangle({ required super.model, super.key });

  static FigmaRectangle fromJson(Map<String, dynamic> json) {
    return FigmaRectangle(model: FigmaSimpleStyleModel.fromJson(json));
  }

  @override
  Widget buildFigmaNode(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: model.style.color,
        backgroundBlendMode: model.style.color == null ? null : BlendMode.values.convertDefault(model.style.blendMode, BlendMode.srcOver),
        border: model.style.border,
        borderRadius: model.style.borderRadius,
      ),
      constraints: model.dimensions!.sizeConstraints,
    );
  }
}