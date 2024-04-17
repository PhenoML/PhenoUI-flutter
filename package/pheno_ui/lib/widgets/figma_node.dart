import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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

abstract class StatelessFigmaNode<T extends FigmaNodeModel> extends StatelessWidget with FigmaNode {
  @override
  final T model;

  const StatelessFigmaNode({
    required this.model,
    super.key
  });

  static StatelessFigmaNode fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('sub classes of StatelessFigmaNode must implement static function `fromJson`');
  }

  @override
  @nonVirtual
  Widget build(BuildContext context) {
    bool visible = isFigmaNodeVisible(context, model);

    if (visible) {
      if (opacity != 1.0) {
        return Opacity(
          opacity: opacity,
          child: buildFigmaNode(context),
        );
      }
      return buildFigmaNode(context);
    }
    return const SizedBox();
  }

  Widget buildFigmaNode(BuildContext context);
}

abstract class StatefulFigmaNode<T extends FigmaNodeModel> extends StatefulWidget with FigmaNode {
  @override
  final T model;

  const StatefulFigmaNode({
    required this.model,
    super.key
  });

  static StatefulFigmaNode fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('sub classes of StatefulFigmaNode must implement static function `fromJson`');
  }

  @override
  StatefulFigmaNodeState createState();
}

abstract class StatefulFigmaNodeState<T extends StatefulFigmaNode> extends State<T> {
  @override
  @nonVirtual
  Widget build(BuildContext context) {
    bool visible = isFigmaNodeVisible(context, widget.model);

    if (visible) {
      if (widget.opacity != 1.0) {
        return Opacity(
          opacity: widget.opacity,
          child: buildFigmaNode(context),
        );
      }
      return buildFigmaNode(context);
    }
    return const SizedBox();
  }

  Widget buildFigmaNode(BuildContext context);
}
