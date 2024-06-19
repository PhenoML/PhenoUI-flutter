import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:pheno_ui/models/figma_dimensions_model.dart';

import '../widgets/figma_node.dart';
import 'layout.dart';

class FigmaFrameLayoutNone extends MultiChildLayoutDelegate {
  final FigmaDimensionsModel dimensions;
  final List<Widget> children;

  FigmaFrameLayoutNone._create({ required this.dimensions, required this.children });

  static CustomMultiChildLayout layoutWithChildren(FigmaDimensionsModel dimensions, List<Widget> children) {
    List<Widget> figmaChildren = [];
    List<LayoutId> layoutChildren = [];

    for (int i = 0, n = children.length; i < n; i++) {
      var child = children[i];
      figmaChildren.add(child);
      layoutChildren.add(LayoutId(id: i, child: child));
    }

    return CustomMultiChildLayout(
      delegate: FigmaFrameLayoutNone._create(
        dimensions: dimensions,
        children: figmaChildren
      ),
      children: layoutChildren,
    );
   }

  @override
  void performLayout(Size size) {
    for (int i = 0, n = children.length; i < n; i++) {
      var child = children[i];
      if (child is! FigmaNode) {
        layoutChild(i, BoxConstraints.loose(size));
        positionChild(i, Offset.zero);
      } else {
        Rect exportRect = computeChildExportRect(dimensions, child.dimensions);
        Rect layoutRect = computeChildLayoutRect(dimensions, child.dimensions, size, exportRect);

        layoutChild(i, BoxConstraints.tight(layoutRect.size));
        positionChild(i, layoutRect.topLeft);
      }
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    // TODO: implement shouldRelayout
    return true;
  }
}