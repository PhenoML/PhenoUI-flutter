import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:pheno_ui/models/figma_frame_model.dart';
import '../parsers/tools/figma_dimensions.dart';
import '../parsers/tools/figma_enum.dart';
import '../layout/figma_frame_layout_none.dart';
import '../models/figma_dimensions_model.dart';
import '../models/figma_layout_model.dart';
import 'figma_node.dart';

Widget? _buildNoneContainer(FigmaDimensionsModel dimensions, List<Widget> children) {
  if (children.isEmpty) {
    return null;
  }

  if (children.length == 1 && children.first is! FigmaNode) {
    return children.first;
  } else if (children.indexWhere((e) => e is FigmaNode) == -1) {
    return Stack(children: children);
  }

  return FigmaFrameLayoutNone.layoutWithChildren(dimensions, children);
}

List<Widget> _addSpacers(List<Widget> widgets, double width, double height) {
  int toAdd = max(widgets.length - 1, 0);
  for (int i = 0; i < toAdd; ++i) {
    widgets.insert(i * 2 + 1, SizedBox(
      width: width,
      height: height,
    ));
  }
  return widgets;
}

Widget? _buildChildrenContainer(List<Widget> children, FigmaFrameModel model) {
  if (children.isEmpty) {
    return null;
  }

  if (model.layout.mode == FigmaLayoutMode.none) {
    return _buildNoneContainer(model.dimensions!, children);
  }

  children = children.map((c) {
    if (c is FigmaNode && c.model.dimensions != null) {
      return dimensionWrapWidget(c, c.model.dimensions!, model.layout.mode);
    }
    return c;
  }).toList();

  // Future Dario:
  // This does not align rows and columns properly when the screen is smaller
  // than the content. This is because the children are not allowed to overflow
  // the parent container. This is a problem with how row and column behave in
  // combination with OverflowBox. A possible solution is to use a custom layout
  // delegate that allows children to overflow the parent container while
  // maintaining the proper alignment and dimensions.
  switch (model.layout.mode) {
    case FigmaLayoutMode.vertical:
      var layout = model.layout;
      if (layout.itemSpacing != 0.0) {
        children = _addSpacers(children, 0.0, layout.itemSpacing);
      }

      return Column(
        mainAxisAlignment: MainAxisAlignment.values.convertDefault(
            layout.mainAxisAlignItems, MainAxisAlignment.start),
        crossAxisAlignment: CrossAxisAlignment.values.convertDefault(
            layout.crossAxisAlignItems, CrossAxisAlignment.start),
        children: children,
      );

    case FigmaLayoutMode.horizontal:
      var layout = model.layout;
      if (layout.wrap == FigmaLayoutWrap.wrap) {
        return Wrap(
          alignment: WrapAlignment.values
              .convertDefault(layout.mainAxisAlignItems, WrapAlignment.start),
          crossAxisAlignment: WrapCrossAlignment.values.convertDefault(
              layout.crossAxisAlignItems, WrapCrossAlignment.start),
          runAlignment: WrapAlignment.values.convertDefault(
              layout.crossAxisAlignContent, WrapAlignment.start),
          spacing: layout.itemSpacing,
          runSpacing: layout.crossAxisSpacing ?? 0.0,
          children: children,
        );
      } else {
        if (layout.itemSpacing != 0.0) {
          children = _addSpacers(children, layout.itemSpacing, 0.0);
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.values.convertDefault(
              layout.mainAxisAlignItems, MainAxisAlignment.start),
          crossAxisAlignment: CrossAxisAlignment.values.convertDefault(
              layout.crossAxisAlignItems, CrossAxisAlignment.start),
          children: children,
        );
      }

    default:
      throw 'Layout mode ${model.layout.mode} not implemented';
  }
}

typedef FigmaFrameConstructor<F extends FigmaFrame, M extends FigmaFrameModel> = F Function({
  required Widget? childrenContainer,
  required M model,
  Key? key,
});

typedef FigmaFrameModelGetter<M extends FigmaFrameModel> = M Function(Map<String, dynamic> json);

F figmaFrameFromJson<F extends FigmaFrame, M extends FigmaFrameModel>(
  Map<String, dynamic> json,
  FigmaFrameConstructor<F, M> constructor,
  FigmaFrameModelGetter<M> modelGetter,
) {
  final M model = modelGetter(json);
  Widget? childrenContainer = _buildChildrenContainer(model.children, model);
  return constructor(model: model, childrenContainer: childrenContainer);
}

class FigmaFrame<T extends FigmaFrameModel> extends StatelessFigmaNode<T> {
  final Widget? childrenContainer;

  const FigmaFrame({
    required this.childrenContainer,
    required super.model,
    super.key
  });

  static FigmaFrame fromJson(Map<String, dynamic> json) {
    return figmaFrameFromJson(json, FigmaFrame.new, FigmaFrameModel.fromJson);
  }

  @override
  Widget buildFigmaNode(BuildContext context) {
    var padding = model.layout.mode == FigmaLayoutMode.none ? null : model.layout.padding;
    var border = model.style.border;
    var blend = model.style.color == null ? null : BlendMode.values.convertDefault(model.style.blendMode, BlendMode.srcOver);

    return Container(
      padding:  padding,
      decoration: BoxDecoration(
        color: model.style.color,
        backgroundBlendMode: blend,
        border: border,
        borderRadius: model.style.borderRadius,
      ),
      constraints: model.dimensions!.sizeConstraints,
      child: childrenContainer,
    );
  }

}