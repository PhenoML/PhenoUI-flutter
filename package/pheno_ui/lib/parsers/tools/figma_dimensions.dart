import 'package:flutter/material.dart';
import '../../models/figma_dimensions_model.dart';
import '../../models/figma_layout_model.dart';

Widget dimensionWrapWidget(Widget widget, FigmaDimensionsModel dimensions, FigmaLayoutMode parentLayoutMode) {
  if (parentLayoutMode == FigmaLayoutMode.none) {
    return widget;
  }

  var width = switch (dimensions.self.widthMode) {
    FigmaDimensionsSizing.fixed => dimensions.self.width,
    FigmaDimensionsSizing.fill => parentLayoutMode == FigmaLayoutMode.horizontal ? null : double.infinity,
    _ => null
  };

  var height = switch (dimensions.self.heightMode) {
    FigmaDimensionsSizing.fixed => dimensions.self.height,
    FigmaDimensionsSizing.fill => parentLayoutMode == FigmaLayoutMode.vertical ? null : double.infinity,
    _ => null
  };

  if (width != null || height != null) {
    widget = SizedBox(
      width: width,
      height: height,
      child: OverflowBox(
        maxWidth: width,
        maxHeight: height,
        // TODO: Future Dario, add alignment based on figma constraints
        alignment: Alignment.topLeft,
        child: widget,
      ),
    );
  }

  if (dimensions.self.widthMode == FigmaDimensionsSizing.hug || dimensions.self.heightMode == FigmaDimensionsSizing.hug) {
    Axis? constrained;
    if (dimensions.self.widthMode != FigmaDimensionsSizing.hug) {
      constrained = Axis.horizontal;
    } else if (dimensions.self.heightMode != FigmaDimensionsSizing.hug) {
      constrained = Axis.vertical;
    }
    widget = UnconstrainedBox(
      constrainedAxis: constrained,
      child: widget,
    );
  }

  if (
  (dimensions.self.widthMode == FigmaDimensionsSizing.fill && parentLayoutMode == FigmaLayoutMode.horizontal)
      || (dimensions.self.heightMode == FigmaDimensionsSizing.fill && parentLayoutMode == FigmaLayoutMode.vertical)
  ) {
    widget = Expanded(child: widget);
  }

  return widget;
}


