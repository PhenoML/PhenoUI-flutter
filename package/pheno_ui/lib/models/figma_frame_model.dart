import 'package:flutter/widgets.dart';

import 'figma_simple_style_model.dart';
import '../pheno_ui.dart';
import 'figma_layout_model.dart';

class FigmaFrameModel extends FigmaSimpleStyleModel {
  final FigmaLayoutModel layout;
  final List<Widget> children;

  FigmaFrameModel.fromJson(Map<String, dynamic> json):
      layout = FigmaLayoutModel.fromJson(json['layout']),
      children = List<Widget>.from(PhenoUi().fromJsonList(json['children'])),
      super.fromJson(json);
}