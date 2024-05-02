import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../models/figma_node_model.dart';
import 'figma_node.dart';

abstract class StatelessFigmaNode<T extends FigmaNodeModel> extends StatelessWidget with FigmaNode {
  @override
  final T model;

  const StatelessFigmaNode({
    required this.model,
    super.key
  });

  void onMount(BuildContext context) { /* nothing */ }

  @override
  createElement() => StatelessFigmaNodeElement(this);

  static StatelessFigmaNode fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('sub classes of StatelessFigmaNode must implement static function `fromJson`');
  }

  @override
  @nonVirtual
  Widget build(BuildContext context) {
    return baseBuildFigmaNode(this, context, buildFigmaNode);
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
      figmaNode.onMount(this);
    }
  }
}