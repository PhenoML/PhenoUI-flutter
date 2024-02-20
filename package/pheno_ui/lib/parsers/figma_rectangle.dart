import 'package:flutter/material.dart';
import 'package:mirai/mirai.dart';
import 'package:pheno_ui/models/figma_simple_style_model.dart';
import 'package:pheno_ui/parsers/tools/figma_dimensions.dart';
import 'package:pheno_ui/parsers/tools/figma_enum.dart';

import '../widgets/figma_node.dart';

class FigmaRectangleParser extends MiraiParser<FigmaSimpleStyleModel> {
  const FigmaRectangleParser();

  @override
  FigmaSimpleStyleModel getModel(Map<String, dynamic> json) => FigmaSimpleStyleModel.fromJson(json);

  @override
  String get type => 'figma_rectangle';

  @override
  Widget parse(BuildContext context, FigmaSimpleStyleModel model) {
    Widget widget = Container(
      decoration: BoxDecoration(
        color: model.style.color,
        backgroundBlendMode: model.style.color == null ? null : BlendMode.values.convertDefault(model.style.blendMode, BlendMode.srcOver),
        border: model.style.border,
        borderRadius: model.style.borderRadius,
      ),
      constraints: model.dimensions!.self.sizeConstraints,
    );

    widget = FigmaNode.withContext(context,
      model: model,
      child: widget,
    );

    return dimensionWrapWidget(widget, model.dimensions!, model.parentLayout);
  }
}