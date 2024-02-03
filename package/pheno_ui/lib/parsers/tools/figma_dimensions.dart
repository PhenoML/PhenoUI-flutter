  import 'dart:math';

import 'package:flutter/material.dart';
import '../../models/figma_dimensions_model.dart';
import '../../models/figma_layout_model.dart';

class FigmaLayoutDelegate extends SingleChildLayoutDelegate {
  final FigmaDimensionsModel dimensions;
  final FigmaLayoutParentValuesModel parentLayout;

  FigmaLayoutDelegate({
    required this.dimensions,
    required this.parentLayout,
    super.relayout
  });

  @override
  Size getSize(BoxConstraints constraints) {
    // print('getSize:$constraints');
    if (parentLayout.mode == FigmaLayoutMode.none) {
      return constraints.biggest;
    }
    return computeContainerSizeAutoLayout(dimensions, constraints);
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    // print('getConstraintsForChild:$constraints');
    if (dimensions.parent == null) {
      return constraints;
    }

    switch (parentLayout.mode) {
      case FigmaLayoutMode.none:
        return computeConstraintsParentLayoutNone(dimensions, constraints);

      default:
        return computeConstraintsParentAutoLayout(dimensions, constraints);
    }
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    // print('getPositionForChild size:$size childSize:$childSize');
    if (dimensions.parent == null) {
      return Offset.zero;
    }

    switch (parentLayout.mode) {
      case FigmaLayoutMode.none:
        return computeOffsetParentLayoutNone(dimensions, size, childSize);

      default:
        return Offset.zero;
    }
  }

  @override
  bool shouldRelayout(covariant FigmaLayoutDelegate oldDelegate) => oldDelegate.dimensions != dimensions && oldDelegate.parentLayout != parentLayout;
}


double _computeContainerDimension(FigmaDimensionsSizing type, double selfValue, double min, double max) {
  switch (type) {
    case FigmaDimensionsSizing.fixed:
      return selfValue;

    case FigmaDimensionsSizing.hug:
    case FigmaDimensionsSizing.fill:
      return max;
  }
}

Size computeContainerSizeAutoLayout(FigmaDimensionsModel model, BoxConstraints constraints) {
  double width = _computeContainerDimension(model.self.widthMode, model.self.width, constraints.minWidth, constraints.maxWidth);
  double height = _computeContainerDimension(model.self.heightMode, model.self.height, constraints.minHeight, constraints.maxHeight);
  return Size(width, height);
}

double _computeDimensionSizeParentLayoutNone(
  FigmaDimensionsConstraintType type,
  double selfOff,
  double selfSize,
  double parentSize,
  double renderSize
) {
  switch (type) {
    case FigmaDimensionsConstraintType.stretch:
      double far = parentSize - selfOff - selfSize;
      return (renderSize - selfOff - far).abs();

    case FigmaDimensionsConstraintType.scale:
      double scale = selfSize / parentSize;
      return renderSize * scale;

    case FigmaDimensionsConstraintType.min:
    case FigmaDimensionsConstraintType.max:
    case FigmaDimensionsConstraintType.center:
      return selfSize;
  }
}

BoxConstraints computeConstraintsParentAutoLayout(FigmaDimensionsModel model, BoxConstraints constraints) {
  if (model.self.widthMode == FigmaDimensionsSizing.fixed || model.self.heightMode == FigmaDimensionsSizing.fixed) {
    return BoxConstraints.tight(computeContainerSizeAutoLayout(model, constraints));
  }
  return constraints;
}

BoxConstraints computeConstraintsParentLayoutNone(FigmaDimensionsModel model, BoxConstraints constraints) {
  var self = model.self;
  var parent = model.parent as FigmaDimensionsParentModel;

  double width = _computeDimensionSizeParentLayoutNone(
      self.constraints.horizontal,
      self.x,
      self.width,
      parent.width,
      constraints.maxWidth
  );

  double height = _computeDimensionSizeParentLayoutNone(
      self.constraints.vertical,
      self.y,
      self.height,
      parent.height,
      constraints.maxHeight,
  );

  return BoxConstraints.tightFor(
    width: width,
    height: height,
  );
}

double _computeDimensionOffsetParentLayoutNone(
  FigmaDimensionsConstraintType type,
  double selfOff,
  double parentOff,
  double selfSize,
  double parentSize,
  double renderSize,
  double renderChildSize
) {
  switch (type) {
    case FigmaDimensionsConstraintType.max:
      double far = parentSize - selfOff - selfSize;
      return renderSize - renderChildSize - far;

    case FigmaDimensionsConstraintType.scale:
      return selfOff * (renderChildSize / selfSize);

    case FigmaDimensionsConstraintType.center:
      double center = selfOff + selfSize * 0.5;
      double scale = center / parentSize;
      return renderSize * scale - renderChildSize * 0.5;

    case FigmaDimensionsConstraintType.stretch:
      double far = parentSize - selfOff - selfSize;
      return selfOff + min(0, renderSize - selfOff - far);

    case FigmaDimensionsConstraintType.min:
      return selfOff;
  }
}

Offset computeOffsetParentLayoutNone(FigmaDimensionsModel model, Size size, Size childSize) {
  var self = model.self;
  var parent = model.parent as FigmaDimensionsParentModel;

  double x = _computeDimensionOffsetParentLayoutNone(
      self.constraints.horizontal,
      self.x,
      parent.x,
      self.width,
      parent.width,
      size.width,
      childSize.width
  );

  double y = _computeDimensionOffsetParentLayoutNone(
      self.constraints.vertical,
      self.y,
      parent.y,
      self.height,
      parent.height,
      size.height,
      childSize.height,
  );

  return Offset(x, y);
}

(FigmaDimensionsSizing, FigmaDimensionsSizing, bool) discernAxisModes(FigmaDimensionsModel dimensions, FigmaLayoutMode parentLayoutMode) {
  if (parentLayoutMode == FigmaLayoutMode.vertical) {
    return (dimensions.self.heightMode, dimensions.self.widthMode, dimensions.self.sizeConstraints.hasBoundedHeight);
  }
  return (dimensions.self.widthMode, dimensions.self.heightMode, dimensions.self.sizeConstraints.hasBoundedWidth);
}

Widget dimensionWrapWidget(Widget widget, FigmaDimensionsModel dimensions, FigmaLayoutParentValuesModel parentLayout) {
  var mode = parentLayout.mode;

  if (mode == FigmaLayoutMode.none) {
    return CustomSingleChildLayout(
      delegate: FigmaLayoutDelegate(dimensions: dimensions, parentLayout: parentLayout),
      child: widget,
    );;
  }

  var width = switch (dimensions.self.widthMode) {
    FigmaDimensionsSizing.fixed => dimensions.self.width,
    FigmaDimensionsSizing.fill => mode == FigmaLayoutMode.horizontal ? null : double.infinity,
    _ => null
  };

  var height = switch (dimensions.self.heightMode) {
    FigmaDimensionsSizing.fixed => dimensions.self.height,
    FigmaDimensionsSizing.fill => mode == FigmaLayoutMode.vertical ? null : double.infinity,
    _ => null
  };

  if (width != null || height != null) {
    widget = SizedBox(
      width: width,
      height: height,
      child: widget,
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
  (dimensions.self.widthMode == FigmaDimensionsSizing.fill && mode == FigmaLayoutMode.horizontal)
      || (dimensions.self.heightMode == FigmaDimensionsSizing.fill && mode == FigmaLayoutMode.vertical)
  ) {
    widget = Expanded(child: widget);
  }

  return widget;
}


