import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:pheno_ui/models/figma_dimensions_model.dart';
import 'package:pheno_ui/widgets/figma_node.dart';

class FigmaFrameLayoutNone extends MultiChildLayoutDelegate {
  final FigmaDimensionsSelfModel dimensions;
  final List<FigmaNode> children;

  FigmaFrameLayoutNone._create({ required this.dimensions, required this.children });

  static CustomMultiChildLayout layoutWithChildren(FigmaDimensionsSelfModel dimensions, List<Widget> children) {
    List<FigmaNode> figmaChildren = [];
    List<LayoutId> layoutChildren = [];

    for (int i = 0, n = children.length; i < n; i++) {
      var child = children[i];
      figmaChildren.add(child is FigmaNode ? child : FigmaNode(child: child));
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
      if (child.dimensions == null) {
        layoutChild(i, BoxConstraints.loose(size));
        positionChild(i, Offset.zero);
      } else {
        var left = child.dimensions!.x;
        var right = dimensions.width - child.dimensions!.x - child.dimensions!.width;
        var top = child.dimensions!.y;
        var bottom = dimensions.height - child.dimensions!.y - child.dimensions!.height;

        var widthScale = (size.width / dimensions.width);
        var heightScale = (size.height / dimensions.height);

        var width = switch (child.dimensions!.constraints.horizontal) {
          FigmaDimensionsConstraintType.min => child.dimensions!.width,
          FigmaDimensionsConstraintType.max => child.dimensions!.width,
          FigmaDimensionsConstraintType.center => child.dimensions!.width,
          FigmaDimensionsConstraintType.stretch => (size.width - left - right).abs(),
          FigmaDimensionsConstraintType.scale => child.dimensions!.width * widthScale,
        };

        var height = switch (child.dimensions!.constraints.vertical) {
          FigmaDimensionsConstraintType.min => child.dimensions!.height,
          FigmaDimensionsConstraintType.max => child.dimensions!.height,
          FigmaDimensionsConstraintType.center => child.dimensions!.height,
          FigmaDimensionsConstraintType.stretch => (size.height - top - bottom).abs(),
          FigmaDimensionsConstraintType.scale => child.dimensions!.height * heightScale,
        };

        layoutChild(i, BoxConstraints.tightFor(
            width: width,
            height: height,
        ));

        var x = switch (child.dimensions!.constraints.horizontal) {
          FigmaDimensionsConstraintType.min => left,
          FigmaDimensionsConstraintType.max => size.width - right,
          FigmaDimensionsConstraintType.center => (left + child.dimensions!.width * 0.5) * widthScale - width * 0.5,
          FigmaDimensionsConstraintType.stretch => min(left, size.width - right),
          FigmaDimensionsConstraintType.scale => left * widthScale,
        };

        var y = switch (child.dimensions!.constraints.vertical) {
          FigmaDimensionsConstraintType.min => top,
          FigmaDimensionsConstraintType.max => size.height - bottom,
          FigmaDimensionsConstraintType.center => (top + child.dimensions!.height * 0.5) * heightScale - height * 0.5,
          FigmaDimensionsConstraintType.stretch => min(top, size.height - bottom),
          FigmaDimensionsConstraintType.scale => top * heightScale,
        };

        positionChild(i, Offset(x, y));
      }
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    // TODO: implement shouldRelayout
    return true;
  }
}