import 'package:flutter/widgets.dart';
import 'package:pheno_ui/models/figma_dimensions_model.dart';

import '../models/figma_node_model.dart';
import '../tools/figma_form_types.dart';
import 'figma_component.dart';

mixin FigmaNode on Widget {
  FigmaNodeModel get model;
  FigmaNodeInfoModel get info => model.info;
  double get opacity => model.opacity;
  FigmaDimensionsModel get dimensions => model.dimensions;
}

bool isFigmaNodeVisible(BuildContext context, FigmaNode node) {
  if (node.model.componentRefs != null && node.model.componentRefs!.containsKey('visible')) {
    var data = FigmaComponentData.maybeOf(context);
    if (data != null) {
      return data.userData.maybeGet(node.model.componentRefs!['visible']) ?? true;
    }
  } else if (node is FigmaFormWidget) {
    return node.isVisible(context);
  }

  return true;
}

Widget baseBuildFigmaNode(FigmaNode widget, BuildContext context, WidgetBuilder builder) {
  bool visible = isFigmaNodeVisible(context, widget);
  Widget child = builder(context);

  if (visible) {
    if (widget.opacity != 1.0) {
      child = Opacity(
        opacity: widget.opacity,
        child: child,
      );
    }
    return widget.model.effects.apply(child);
  }
  return const SizedBox();
}
