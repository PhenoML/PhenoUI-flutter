  import 'dart:math';

import 'package:flutter/material.dart';
import 'package:phenoui_flutter/models/figma_dimensions_model.dart';

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


