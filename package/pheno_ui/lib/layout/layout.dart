import 'dart:math';
import 'dart:ui';

import 'package:pheno_ui/models/figma_dimensions_model.dart';

Rect computeChildExportRect(FigmaDimensionsModel parentDim, FigmaDimensionsModel childDim) {
  var left = childDim.x;
  var right = parentDim.width - childDim.x - childDim.width;
  var top = childDim.y;
  var bottom = parentDim.height - childDim.y - childDim.height;

  return Rect.fromLTRB(left, top, right, bottom);
}

Rect computeChildLayoutRect(FigmaDimensionsModel parentDim, FigmaDimensionsModel childDim, Size parentSize, Rect exportRect) {
  var widthScale = (parentSize.width / parentDim.width);
  var heightScale = (parentSize.height / parentDim.height);

  var width = switch (childDim.constraints.horizontal) {
    FigmaDimensionsConstraintType.min => childDim.width,
    FigmaDimensionsConstraintType.max => childDim.width,
    FigmaDimensionsConstraintType.center => childDim.width,
    FigmaDimensionsConstraintType.stretch => (parentSize.width - exportRect.left - exportRect.right).abs(),
    FigmaDimensionsConstraintType.scale => childDim.width * widthScale,
  };

  var height = switch (childDim.constraints.vertical) {
    FigmaDimensionsConstraintType.min => childDim.height,
    FigmaDimensionsConstraintType.max => childDim.height,
    FigmaDimensionsConstraintType.center => childDim.height,
    FigmaDimensionsConstraintType.stretch => (parentSize.height - exportRect.top - exportRect.bottom).abs(),
    FigmaDimensionsConstraintType.scale => childDim.height * heightScale,
  };

  var x = switch (childDim.constraints.horizontal) {
    FigmaDimensionsConstraintType.min => exportRect.left,
    FigmaDimensionsConstraintType.max => parentSize.width - exportRect.right - width,
    FigmaDimensionsConstraintType.center => parentSize.width * 0.5 + (exportRect.left + childDim.width * 0.5) - parentDim.width * 0.5 - width * 0.5,
    FigmaDimensionsConstraintType.stretch => min(exportRect.left, parentSize.width - exportRect.right),
    FigmaDimensionsConstraintType.scale => exportRect.left * widthScale,
  };

  var y = switch (childDim.constraints.vertical) {
    FigmaDimensionsConstraintType.min => exportRect.top,
    FigmaDimensionsConstraintType.max => parentSize.height - exportRect.bottom - height,
    FigmaDimensionsConstraintType.center => parentSize.height * 0.5 + (exportRect.top + childDim.height * 0.5) - parentDim.height * 0.5 - height * 0.5,
    FigmaDimensionsConstraintType.stretch => min(exportRect.top, parentSize.height - exportRect.bottom),
    FigmaDimensionsConstraintType.scale => exportRect.top * heightScale,
  };
  
  return Offset(x, y) & Size(width, height);
}
