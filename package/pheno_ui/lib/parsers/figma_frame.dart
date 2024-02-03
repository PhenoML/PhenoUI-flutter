import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mirai/mirai.dart';
import './tools/figma_dimensions.dart';
import '../models/figma_dimensions_model.dart';
import '../models/figma_layout_model.dart';
import './tools/figma_enum.dart';
import '../models/figma_frame_model.dart';

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
    switch (model.layout.self.mode) {
      case FigmaLayoutMode.none:
        childrenContainer = Stack(children: children);
        break;

      case FigmaLayoutMode.vertical:
        var layout = model.layout.self;
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
        var layout = model.layout.self;
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
        throw 'Layout mode ${model.layout.self.mode} not implemented';
    }

    Widget widget = Container(
      padding:  model.layout.self.mode == FigmaLayoutMode.none ? null : model.layout.self.padding,
      decoration: BoxDecoration(
        color: model.style.color,
        border: model.style.border,
        borderRadius: model.style.borderRadius,
      ),
      constraints: model.dimensions.self.sizeConstraints,
      child: childrenContainer,
    );
    widget = model.wrapper(widget);

    switch (model.layout.parent.mode) {
      case FigmaLayoutMode.none:
        if (model.dimensions.parent != null && (model.dimensions.self.widthMode == FigmaDimensionsSizing.hug || model.dimensions.self.heightMode == FigmaDimensionsSizing.hug)) {
          Axis? axis;
          if (model.dimensions.self.widthMode != FigmaDimensionsSizing.hug) {
            axis = Axis.horizontal;
          } else if (model.dimensions.self.heightMode != FigmaDimensionsSizing.hug) {
            axis = Axis.vertical;
          }
          widget = UnconstrainedBox(constrainedAxis: axis, child: widget);
        } else {
          widget = CustomSingleChildLayout(
            delegate: FigmaLayoutDelegate(dimensions: model.dimensions, parentLayout: model.layout.parent),
            child: widget,
          );
        }
        break;

      default:
        var (mainAxis, crossAxis, hasSizeConstraints) = discernAxisModes(model.dimensions, model.layout.parent.mode);
        if (mainAxis == FigmaDimensionsSizing.fixed || crossAxis == FigmaDimensionsSizing.fixed) {
          widget = CustomSingleChildLayout(
              delegate: FigmaLayoutDelegate(dimensions: model.dimensions, parentLayout: model.layout.parent),
              child: widget,
          );
        }

        if (mainAxis == FigmaDimensionsSizing.fill || model.layout.self.grow != 0) {
          // Future Dario: fill sizing and `Wrap` do not work, I am deciding to
          // let it crash for now because `Expanded` simply doesn't work in
          // combination with `Wrap`. Two possible solutions, if we _really_
          // need to use fill sizing within `Wrap`:
          // 1. Write a SingleChildLayoutDelegate (or similar) to support the
          //    use case.
          // 2. Use the widget referenced in the SO:
          //    https://stackoverflow.com/questions/74170550/flutter-wrap-row-of-expanded-widgets
          widget = Flexible(
            flex: hasSizeConstraints ? 0 : 1,
            fit: FlexFit.tight,
            child: widget
          );
        } else if (mainAxis == FigmaDimensionsSizing.hug) {
          Axis? axis;
          if (model.dimensions.self.widthMode != FigmaDimensionsSizing.hug) {
            axis = Axis.horizontal;
          } else if (model.dimensions.self.heightMode != FigmaDimensionsSizing.hug) {
            axis = Axis.vertical;
          }
          widget = UnconstrainedBox(constrainedAxis: axis, child: widget);
        }
        break;
    }

    return widget;
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