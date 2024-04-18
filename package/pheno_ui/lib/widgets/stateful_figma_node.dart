import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../models/figma_node_model.dart';
import 'figma_node.dart';

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