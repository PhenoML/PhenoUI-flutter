import 'package:flutter/widgets.dart';
import 'package:pheno_ui/models/figma_dimensions_model.dart';

import '../models/figma_node_model.dart';
import 'figma_component.dart';

mixin FigmaNode on Widget {
  FigmaNodeModel get model;
  FigmaNodeInfoModel get info => model.info;
  double get opacity => model.style?.opacity ?? 1.0;
  FigmaDimensionsModel? get dimensions => model.dimensions;
}

bool isFigmaNodeVisible(BuildContext context, FigmaNodeModel model) {
  if (model.componentRefs != null && model.componentRefs!.containsKey('visible')) {
    var data = FigmaComponentData.maybeOf(context);
    if (data != null) {
      return data.userData.maybeGet(model.componentRefs!['visible']) ?? true;
    }
  }
  return true;
}
