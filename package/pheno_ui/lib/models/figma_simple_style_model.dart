import 'package:pheno_ui/models/figma_node_model.dart';

import 'figma_layout_model.dart';
import 'figma_style_model.dart';

class FigmaSimpleStyleModel extends FigmaNodeModel {
  final FigmaStyleModel style;
  final FigmaLayoutParentValuesModel parentLayout;

  FigmaSimpleStyleModel.fromJson(Map<String, dynamic> json):
        style = FigmaStyleModel.fromJson(json['style']),
        parentLayout = FigmaLayoutParentValuesModel.fromJson(json['parentLayout']),
        super.fromJson(json);
}