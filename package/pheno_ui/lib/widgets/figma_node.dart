import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../models/figma_node_model.dart';
import '../parsers/figma_component.dart';

mixin FigmaNode on Widget {
  FigmaNodeModel get model;
  get info => model.info;
  get opacity => model.style?.opacity ?? 1.0;
  get dimensions => model.dimensions?.self;
}

bool isFigmaNodeVisible(BuildContext context, FigmaNodeModel model) {
  // if (model.componentRefs != null && model.componentRefs!.containsKey('visible')) {
  //   var data = FigmaComponentData.maybeOf(context);
  //   if (data != null) {
  //     return data.userData.maybeGet(model.componentRefs!['visible']) ?? true;
  //   }
  // }
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
    throw UnimplementedError('sub classes of StatelessFigmaNode must implement a factory constructor `fromJson`');
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
    throw UnimplementedError('sub classes of StatefulFigmaNode must implement a factory constructor `fromJson`');
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
