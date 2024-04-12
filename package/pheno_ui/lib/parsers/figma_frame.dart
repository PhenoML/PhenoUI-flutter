import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mirai/mirai.dart';
import 'package:pheno_ui/models/figma_style_model.dart';
import '../widgets/figma_frame_layout_none.dart';
import '../widgets/figma_node_old.dart';
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

  Widget? buildNoneContainer(
      FigmaDimensionsSelfModel dimensions, List<Widget> children) {
    if (children.isEmpty) {
      return null;
    }

    if (children.length == 1 && children.first is! FigmaNodeOld) {
      return children.first;
    } else if (children.indexWhere((e) => e is FigmaNodeOld) == -1) {
      return Stack(children: children);
    }

    return FigmaFrameLayoutNone.layoutWithChildren(dimensions, children);
  }

  Widget? buildChildrenContainer(BuildContext context, FigmaFrameModel model) {
    List<Widget> children = model.children
        .map((value) => Mirai.fromJson(value, context) ?? const SizedBox())
        .toList();
    switch (model.layout.self.mode) {
      case FigmaLayoutMode.none:
        return buildNoneContainer(model.dimensions!.self, children);

      case FigmaLayoutMode.vertical:
        var layout = model.layout.self;
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
        var layout = model.layout.self;
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
        throw 'Layout mode ${model.layout.self.mode} not implemented';
    }
  }

  Widget buildWidgetWithScale(BuildContext context, FigmaFrameModel model, double scaleX, double scaleY) {
    var childrenContainer = buildChildrenContainer(context, model);

    var padding = model.layout.self.mode == FigmaLayoutMode.none ? null : EdgeInsets.fromLTRB(
      model.layout.self.padding.left * scaleX,
      model.layout.self.padding.top * scaleY,
      model.layout.self.padding.right * scaleX,
      model.layout.self.padding.bottom * scaleY,
    );

    var border = model.style.border == null ? null : FigmaStyleBorder(
      top: model.style.border!.top.scale(scaleY),
      right: model.style.border!.right.scale(scaleX),
      bottom: model.style.border!.bottom.scale(scaleY),
      left: model.style.border!.left.scale(scaleX),
    );

    var boxConstraints = BoxConstraints(
      minWidth: model.dimensions!.self.sizeConstraints.minWidth * scaleX,
      maxWidth: model.dimensions!.self.sizeConstraints.maxWidth * scaleX,
      minHeight: model.dimensions!.self.sizeConstraints.minHeight * scaleY,
      maxHeight: model.dimensions!.self.sizeConstraints.maxHeight * scaleY,
    );

    return Container(
      padding:  padding,
      decoration: BoxDecoration(
        color: model.style.color,
        backgroundBlendMode: model.style.color == null ? null : BlendMode.values.convertDefault(model.style.blendMode, BlendMode.srcOver),
        border: border,
        borderRadius: model.style.borderRadius == null ? null : model.style.borderRadius! * min(scaleX, scaleY),
      ),
      constraints: model.dimensions!.self.sizeConstraints,
      child: childrenContainer,
    );
  }

  @override
  Widget parse(BuildContext context, FigmaFrameModel model) {
    Widget widget;
    widget = model.wrapper(context, false, (context) => buildWidgetWithScale(context, model, 1.0, 1.0));

    switch (model.layout.parent.mode) {
      case FigmaLayoutMode.none:
        break;

      default:
        var (mainAxis, crossAxis, hasSizeConstraints) = discernAxisModes(model.dimensions!, model.layout.parent.mode);
        if (mainAxis == FigmaDimensionsSizing.fixed || crossAxis == FigmaDimensionsSizing.fixed) {
          widget = CustomSingleChildLayout(
              delegate: FigmaLayoutDelegate(dimensions: model.dimensions!, parentLayout: model.layout.parent),
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
          if (model.dimensions!.self.widthMode != FigmaDimensionsSizing.hug) {
            axis = Axis.horizontal;
          } else if (model.dimensions!.self.heightMode != FigmaDimensionsSizing.hug) {
            axis = Axis.vertical;
          }
          widget = UnconstrainedBox(constrainedAxis: axis, child: widget);
        }
        break;
    }

    return FigmaNodeOld.withContext(context,
      model: model,
      child: widget,);
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