import 'package:flutter/widgets.dart';
import 'package:pheno_ui/models/figma_dimensions_model.dart';
import 'package:pheno_ui/models/figma_node_model.dart';

import '../parsers/figma_component.dart';

class FigmaNode extends StatelessWidget {
  final FigmaNodeInfoModel? info;
  final FigmaDimensionsSelfModel? dimensions;
  final double opacity;
  final bool visible;
  final Widget? child;

  const FigmaNode({this.info, this.dimensions, this.opacity = 1.0, this.visible = true, this.child, super.key});

  factory FigmaNode.withContext(BuildContext context, { required FigmaNodeModel model, Widget? child }) {
    bool visible = true;

    if (model.componentRefs != null && model.componentRefs!.containsKey('visible')) {
      var data = FigmaComponentData.maybeOf(context);
      if (data != null) {
        visible = data.userData.maybeGet(model.componentRefs!['visible']) ?? true;
      }
    }

    return FigmaNode(
      info: model.info,
      dimensions: model.dimensions!.self,
      visible: visible,
      opacity: model.style?.opacity ?? 1.0,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (visible && child != null) {
      if (opacity != 1.0) {
        return Opacity(
          opacity: opacity,
          child: child!,
        );
      }
      return child!;
    }
    return const SizedBox();
  }
}