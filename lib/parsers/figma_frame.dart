import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mirai/mirai.dart';
import 'package:phenoui_flutter/models/figma_dimensions_model.dart';
import 'package:phenoui_flutter/models/figma_layout_model.dart';
import 'package:phenoui_flutter/parsers/tools/figma_dimensions.dart';
import 'package:phenoui_flutter/parsers/tools/figma_enum.dart';
import '../models/figma_frame_model.dart';


class FigmaFrameLayoutDelegate extends SingleChildLayoutDelegate {
  FigmaFrameModel model;
  FigmaFrameLayoutDelegate({required this.model, super.relayout});

  @override
  Size getSize(BoxConstraints constraints) {
    if (model.layout.parentLayoutMode == FigmaLayoutMode.none) {
      return constraints.biggest;
    }
    return computeContainerSizeAutoLayout(model.dimensions, constraints);
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    if (model.dimensions.parent == null) {
      return constraints;
    }

    switch (model.layout.parentLayoutMode) {
      case FigmaLayoutMode.none:
        return computeConstraintsParentLayoutNone(model.dimensions, constraints);

      default:
        return computeConstraintsParentAutoLayout(model.dimensions, constraints);
    }
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    if (model.dimensions.parent == null) {
      return Offset.zero;
    }

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
    List<Widget> children = model.children.map((value) => Mirai.fromJson(value, context) ?? const SizedBox()).toList();

    Widget childrenContainer;
    switch (model.layout.layoutMode) {
      case FigmaLayoutMode.none:
        childrenContainer = Stack(children: children);
        break;

      case FigmaLayoutMode.vertical:
        var layout = model.layout.self as FigmaLayoutValuesModel;
        if (layout.itemSpacing != 0.0) {
          children = _addSpacers(children, 0.0, layout.itemSpacing);
        }

        childrenContainer = Column(
          mainAxisAlignment: MainAxisAlignment.values.convertDefault(layout.mainAxisAlignItems, MainAxisAlignment.start),
          crossAxisAlignment: CrossAxisAlignment.values.convertDefault(layout.crossAxisAlignItems, CrossAxisAlignment.start),
          children: children,
        );
        break;

      case FigmaLayoutMode.horizontal:
        var layout = model.layout.self as FigmaLayoutValuesModel;
        if (layout.wrap == FigmaLayoutWrap.wrap) {
          childrenContainer = Wrap(
            alignment: WrapAlignment.values.convertDefault(layout.mainAxisAlignItems, WrapAlignment.start),
            crossAxisAlignment: WrapCrossAlignment.values.convertDefault(layout.crossAxisAlignItems, WrapCrossAlignment.start),
            runAlignment: WrapAlignment.values.convertDefault(layout.crossAxisAlignContent, WrapAlignment.start),
            spacing: layout.itemSpacing,
            runSpacing: layout.crossAxisSpacing ?? 0.0,
            children: children,
          );
        } else {
          if (layout.itemSpacing != 0.0) {
            children = _addSpacers(children, layout.itemSpacing, 0.0);
          }

          childrenContainer = Row(
            mainAxisAlignment: MainAxisAlignment.values.convertDefault(layout.mainAxisAlignItems, MainAxisAlignment.start),
            crossAxisAlignment: CrossAxisAlignment.values.convertDefault(layout.crossAxisAlignItems, CrossAxisAlignment.start),
            children: children,
          );
        }

      default:
        throw 'Layout mode ${model.layout.self?.mode} not implemented';
    }

    Widget widget;
    switch (model.layout.parentLayoutMode) {
      case FigmaLayoutMode.none:
        widget = CustomSingleChildLayout(
          delegate: FigmaFrameLayoutDelegate(model: model),
          child: Container(
            padding: model.layout.self?.padding,
            decoration: BoxDecoration(
              color: model.style.color,
              borderRadius: model.style.borderRadius,
            ),
            constraints: model.dimensions.self.sizeConstraints,
            child: childrenContainer,
          ),
        );

      default:
        var parentLayout = model.layout.parent as FigmaLayoutValuesModel;

        Size size = computeContainerSizeAutoLayout(model.dimensions, const BoxConstraints(
          minWidth: 0.0,
          minHeight: 0.0,
          maxWidth: double.infinity,
          maxHeight: double.infinity,
        ));

        widget = Container(
          padding: model.layout.self?.padding,
          decoration: BoxDecoration(
          color: model.style.color,
          borderRadius: model.style.borderRadius,
          ),
          constraints: model.dimensions.self.sizeConstraints,
          width: size.width,
          height: size.height,
          child: childrenContainer,
        );

        if (model.layout.self != null) {
          var (mainAxis, crossAxis) = _discernAxisModes(model);
          if (crossAxis == FigmaDimensionsSizing.fixed || crossAxis == FigmaDimensionsSizing.hug) {
            widget = CustomSingleChildLayout(
                delegate: FigmaFrameLayoutDelegate(model: model),
                child: widget,
            );
          }

          var layout = model.layout.self as FigmaLayoutValuesModel;
          if (layout.grow != 0.0 || mainAxis == FigmaDimensionsSizing.fill) {
            widget = Expanded(child: widget);
          } else if (mainAxis == FigmaDimensionsSizing.hug) {
            widget = UnconstrainedBox(child: widget);
          }
        }
    }

    return widget;
  }

  (FigmaDimensionsSizing, FigmaDimensionsSizing) _discernAxisModes(FigmaFrameModel model) {
    if (model.layout.parent?.mode == FigmaLayoutMode.vertical) {
      return (model.dimensions.self.heightMode, model.dimensions.self.widthMode);
    }
    return (model.dimensions.self.widthMode, model.dimensions.self.heightMode);
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
}