import 'package:flutter/widgets.dart';
import 'package:pheno_ui/pheno_ui.dart';

import 'figma_layout_model.dart';
import 'figma_node_model.dart';
import 'figma_style_model.dart';

class FigmaFrameModel extends FigmaNodeModel {
  final FigmaLayoutModel layout;
  final List<Widget> children;

  @override
  FigmaStyleModel get style => super.style!;

  FigmaFrameModel.fromJson(Map<String, dynamic> json):
      layout = FigmaLayoutModel.fromJson(json['layout']),
      children = List<Widget>.from(PhenoUi().fromJsonList(json['children'])),
      super.fromJson(json);
}