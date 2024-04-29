import 'package:flutter/widgets.dart';
import 'package:pheno_ui/models/figma_dimensions_model.dart';
import 'package:pheno_ui/models/figma_node_model.dart';

import '../layout/figma_frame_layout_none.dart';
import '../models/figma_tile_child_model.dart';
import 'figma_node.dart';
import 'stateless_figma_node.dart';

class FigmaTileChild extends StatelessFigmaNode<FigmaTileChildModel> {
  const FigmaTileChild({required super.model, super.key});

  static FigmaTileChild fromJson(Map<String, dynamic> json) {
    final FigmaTileChildModel model = FigmaTileChildModel.fromJson(json);
    return FigmaTileChild(model: model);
  }

  @override
  Widget buildFigmaNode(BuildContext context) {
    if (model.userData.maybeGet('vertical') == true) {
      throw Exception('Vertical tile is not supported');
    }
    if (model.horizontalDirection == FigmaTileChildHorizontalDirection.center) {
      throw Exception('Center horizontal direction is not supported');
    }

    return LayoutBuilder(builder: (context, constraints) {
      List<Widget> children = [];

      if (model.horizontalDirection == FigmaTileChildHorizontalDirection.right) {
        double start = model.childPosition.dx;
        int count = ((constraints.maxWidth - start) / model.childSize.width).ceil();

        for (int i = 0; i < count; i++) {
          Widget child = _FigmaTileChild(
            x: start + i * model.childSize.width,
            child: model.child,
          );
          children.add(child);
        }
      } else {
        double start = constraints.maxWidth - (model.dimensions.width - model.childPosition.dx);
        int count = (start / model.childSize.width).ceil() + 1;

        for (int i = 0; i < count; i++) {
          Widget child = _FigmaTileChild(
            x: model.childPosition.dx - i * model.childSize.width,
            child: model.child,
          );
          children.add(child);
        }
      }

      Widget child = FigmaFrameLayoutNone.layoutWithChildren(model.dimensions, children);
      return Container(
        constraints: model.dimensions.sizeConstraints,
        child: child,
      );
    });
  }
}

class _FigmaTileChild extends StatelessWidget with FigmaNode {
  final FigmaNode child;

  @override
  late final FigmaDimensionsModel dimensions;

  @override
  FigmaNodeModel get model => child.model;

  _FigmaTileChild({
    required this.child,
    super.key,
    double? x,
    double? y,
  }) {
    dimensions = FigmaDimensionsModel.copy(
      child.dimensions,
      x: x,
      y: y,
    );
  }

  @override
  Widget build(BuildContext context) {
    return child;
  }
}