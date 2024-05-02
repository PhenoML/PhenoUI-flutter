import 'package:flutter/widgets.dart';

import 'figma_simple_style_model.dart';
import '../pheno_ui.dart';
import 'figma_layout_model.dart';

class FigmaFrameModel extends FigmaSimpleStyleModel {
  final FigmaLayoutModel layout;
  final List<Widget> children;
  late final Clip clipBehavior;

  FigmaFrameModel.fromJson(Map<String, dynamic> json):
      layout = FigmaLayoutModel.fromJson(json['layout']),
      children = List<Widget>.from(PhenoUi().fromJsonList(json['children'])),
      super.fromJson(json)
  {
    if (json['clipsContent'] == true) {
      if (
        style.borderRadius != null
        && (
          style.borderRadius!.topLeft != Radius.zero
          || style.borderRadius!.topRight != Radius.zero
          || style.borderRadius!.bottomLeft != Radius.zero
          || style.borderRadius!.bottomRight != Radius.zero
        )
      ) {
        clipBehavior = Clip.antiAlias;
      } else {
        clipBehavior = Clip.hardEdge;
      }
    } else {
      clipBehavior = Clip.none;
    }
  }
}