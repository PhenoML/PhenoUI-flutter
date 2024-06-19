import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:pheno_ui/models/figma_frame_model.dart';
import '../layout/figma_frame_layout_auto.dart';
import '../layout/figma_frame_layout_none.dart';
import '../tools/figma_dimensions.dart';
import '../tools/figma_enum.dart';
import '../models/figma_dimensions_model.dart';
import '../models/figma_layout_model.dart';
import 'figma_node.dart';
import 'stateless_figma_node.dart';

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

Widget? _buildAutoContainer(FigmaDimensionsModel dimensions, FigmaLayoutModel layout, List<Widget> children) {
  if (children.isEmpty) {
    return null;
  }

  return FigmaFrameLayoutAuto(
    dimensions: dimensions,
    layout: layout,
    children: children,
  );
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

Widget? _buildChildrenContainer(List<Widget> children, FigmaFrameModel model, BuildContext context) {
  children = children.where((c) {
    if (c is FigmaNode) {
      return isFigmaNodeVisible(context, c);
    }
    return true;
  }).toList();

  if (children.isEmpty) {
    return null;
  }

  if (model.layout.mode == FigmaLayoutMode.none) {
    return _buildNoneContainer(model.dimensions, children);
  }
  return _buildAutoContainer(model.dimensions, model.layout, children);
}

typedef FigmaFrameConstructor<F extends FigmaNode, M extends FigmaFrameModel> = F Function({
  required M model,
  Key? key,
});

typedef FigmaFrameModelGetter<M extends FigmaFrameModel> = M Function(Map<String, dynamic> json);

class FigmaFrame<T extends FigmaFrameModel> extends StatelessFigmaNode<T> {
  const FigmaFrame({
    required super.model,
    super.key
  });

  static F fromJson<F extends FigmaNode, M extends FigmaFrameModel>(
    Map<String, dynamic> json,
    [
      FigmaFrameConstructor<F, M>? constructor,
      FigmaFrameModelGetter<M>? modelGetter
    ]
  ) {
    final M model = modelGetter == null ?
      FigmaFrameModel.fromJson(json) as M :
      modelGetter(json);

    return constructor == null ?
      FigmaFrame(model: model) as F:
      constructor(model: model);
  }

  static Widget buildFigmaFrame<M extends FigmaFrameModel>(
    BuildContext context,
    M model
  ) {
    Widget? childrenContainer = _buildChildrenContainer(model.children, model, context);
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
      constraints: model.dimensions.sizeConstraints,
      clipBehavior: model.clipBehavior,
      child: childrenContainer,
    );
  }

  @override
  Widget buildFigmaNode(BuildContext context) {
    return buildFigmaFrame(context, model);
  }
}
