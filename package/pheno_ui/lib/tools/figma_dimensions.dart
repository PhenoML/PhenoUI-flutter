import 'package:flutter/material.dart';
import '../../models/figma_dimensions_model.dart';
import '../../models/figma_layout_model.dart';

Widget dimensionWrapWidget(Widget widget, FigmaDimensionsModel dimensions, FigmaLayoutModel layout) {
  if (layout.mode == FigmaLayoutMode.none) {
    return widget;
  }

  var width = switch (dimensions.widthMode) {
    FigmaDimensionsSizing.fixed => dimensions.width,
    FigmaDimensionsSizing.fill => layout.mode == FigmaLayoutMode.horizontal ? null : double.infinity,
    _ => null
  };

  var height = switch (dimensions.heightMode) {
    FigmaDimensionsSizing.fixed => dimensions.height,
    FigmaDimensionsSizing.fill => layout.mode == FigmaLayoutMode.vertical ? null : double.infinity,
    _ => null
  };

  if (
    (width != null && width != double.infinity)
    || (height != null && height != double.infinity)
  ) {
    var mainAxisAlign = switch (layout.mainAxisAlignItems) {
      FigmaLayoutAxisAlignItems.start => -1.0,
      FigmaLayoutAxisAlignItems.end => 1.0,
      _ => 0.0,
    };

    var crossAxisAlign = switch (layout.crossAxisAlignItems) {
      FigmaLayoutAxisAlignItems.start => -1.0,
      FigmaLayoutAxisAlignItems.end => 1.0,
      _ => 0.0,
    };

    var alignment = layout.mode == FigmaLayoutMode.vertical
        ? Alignment(crossAxisAlign, mainAxisAlign)
        : Alignment(mainAxisAlign, crossAxisAlign);

    widget = ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: width == double.infinity ? 0 : width ?? 0,
        maxWidth: width ?? double.infinity,
        minHeight: height == double.infinity ? 0 : height ?? 0,
        maxHeight: height ?? double.infinity,
      ),
      child: OverflowBox(
        maxWidth: width == double.infinity ? null : width,
        maxHeight: height == double.infinity ? null : height,
        alignment: alignment,
        child: widget
      ),
    );
  }

  if (dimensions.widthMode == FigmaDimensionsSizing.hug || dimensions.heightMode == FigmaDimensionsSizing.hug) {
    Axis? constrained;
    if (dimensions.widthMode != FigmaDimensionsSizing.hug) {
      constrained = Axis.horizontal;
    } else if (dimensions.heightMode != FigmaDimensionsSizing.hug) {
      constrained = Axis.vertical;
    }
    widget = UnconstrainedBox(
      constrainedAxis: constrained,
      child: widget,
    );
  }

  if (
  (dimensions.widthMode == FigmaDimensionsSizing.fill && layout.mode == FigmaLayoutMode.horizontal)
      || (dimensions.heightMode == FigmaDimensionsSizing.fill && layout.mode == FigmaLayoutMode.vertical)
  ) {
    widget = Expanded(child: widget);
  }

  return widget;
}


