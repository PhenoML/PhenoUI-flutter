import 'package:flutter/widgets.dart';
import 'package:pheno_ui/models/figma_dimensions_model.dart';
import 'package:pheno_ui/models/figma_node_model.dart';

import '../parsers/figma_component.dart';

class FigmaNode extends StatelessWidget {
  final FigmaNodeInfoModel? info;
  final FigmaDimensionsSelfModel? dimensions;
  final bool visible;
  final Widget? child;

  const FigmaNode({this.info, this.dimensions, this.visible = true, this.child, super.key});

  factory FigmaNode.withContext(BuildContext context, { required FigmaNodeModel model, Widget? child }) {
    bool visible = true;

    if (model.componentRefs != null && model.componentRefs!.containsKey('visible')) {
      var data = FigmaComponentData.maybeOf(context);
      if (data != null) {
        visible = data.userData[model.componentRefs!['visible']] ?? true;
      }
    }

    return FigmaNode(
      info: model.info,
      dimensions: model.dimensions!.self,
      visible: visible,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (visible && child != null) {
      return child!;
    }
    return const SizedBox();
  }
}