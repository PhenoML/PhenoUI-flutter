import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:mirai/mirai.dart';
import 'package:phenoui_flutter/models/figma_dimensions_model.dart';
import 'package:phenoui_flutter/models/figma_layout_model.dart';
import 'package:phenoui_flutter/parsers/tools/figma_dimensions.dart';
import '../models/figma_frame_model.dart';


class FigmaFrameLayoutDelegate extends SingleChildLayoutDelegate {
  FigmaFrameModel model;
  FigmaFrameLayoutDelegate({required this.model, super.relayout});

  @override
  Size getSize(BoxConstraints constraints) {
    return constraints.biggest;
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    switch (model.layout.parentLayoutMode) {
      case FigmaLayoutMode.none:
        return computeConstraintsParentLayoutNone(model.dimensions, constraints);

      default:
        return constraints;
    }
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    switch (model.layout.parentLayoutMode) {
      case FigmaLayoutMode.none:
        return computeOffsetParentLayoutNone(model.dimensions, size, childSize);

      default:
        return Offset.zero;
    }
  }

  @override
  bool shouldRelayout(covariant FigmaFrameLayoutDelegate oldDelegate) => oldDelegate.model != model;
}

class FigmaFrameParser extends MiraiParser<FigmaFrameModel> {
  const FigmaFrameParser();

  @override
  FigmaFrameModel getModel(Map<String, dynamic> json) => FigmaFrameModel.fromJson(json);

  @override
  String get type => 'figma-frame';

  @override
  Widget parse(BuildContext context, FigmaFrameModel model) {
    Widget childrenContainer;
    if (model.layout.layoutMode == FigmaLayoutMode.none) {
      childrenContainer = Stack(children: model.children.map((value) => Mirai.fromJson(value, context) ?? const SizedBox(),).toList());
    } else {
      throw 'Layout mode ${model.layout.self?.mode} not implemented';
    }

    if (model.dimensions.parent == null) {
      return Container(
        color: model.style.color,
        child: childrenContainer,
      );
    }

    // TODO: This could be wrapped in an opacity widget, but let's wait to see if it's a feature we need.
    return CustomSingleChildLayout(
      delegate: FigmaFrameLayoutDelegate(model: model),
      child: Container(
        decoration: BoxDecoration(
          color: model.style.color,
          borderRadius: model.style.borderRadius,
        ),
      ),
    );
  }
}