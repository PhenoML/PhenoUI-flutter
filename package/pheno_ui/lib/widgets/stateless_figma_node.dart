import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../models/figma_node_model.dart';
import 'figma_node.dart';

abstract class StatelessFigmaNode<T extends FigmaNodeModel> extends StatelessWidget with FigmaNode {
  final void Function(BuildContext context)? onMount;

  @override
  final T model;

  const StatelessFigmaNode({
    required this.model,
    this.onMount,
    super.key
  });

  @override
  createElement() => StatelessFigmaNodeElement(this);

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

class StatelessFigmaNodeElement extends StatelessElement {
  StatelessFigmaNodeElement(StatelessFigmaNode super.widget);

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    if (widget is StatelessFigmaNode) {
      StatelessFigmaNode figmaNode = widget as StatelessFigmaNode;
      if (figmaNode.onMount != null) {
        figmaNode.onMount!(this);
      }
    }
  }
}