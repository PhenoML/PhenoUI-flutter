import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../models/figma_dimensions_model.dart';
import '../models/figma_layout_model.dart';
import '../widgets/figma_node.dart';
import 'layout.dart';

class FigmaFrameLayoutAuto extends MultiChildRenderObjectWidget {
  final FigmaDimensionsModel dimensions;
  final FigmaLayoutModel layout;

  const FigmaFrameLayoutAuto({
    required this.dimensions,
    required this.layout,
    required super.children,
    super.key,
  });

  @override
  createElement() => FigmaFrameLayoutAutoElement(this);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return FigmaFrameLayoutAutoRenderBox(
      figmaDimensions: dimensions,
      figmaLayout: layout,
    );
  }

  @override
  void updateRenderObject(BuildContext context, FigmaFrameLayoutAutoRenderBox renderObject) {
    renderObject.figmaDimensions = dimensions;
    renderObject.figmaLayout = layout;
    renderObject.markNeedsLayout();
  }
}

class FigmaFrameLayoutAutoParentData extends ContainerBoxParentData<RenderBox>
    with ContainerParentDataMixin<RenderBox> {
  FigmaDimensionsModel? dimensions;
}

class FigmaFrameLayoutAutoElement extends MultiChildRenderObjectElement {
  FigmaFrameLayoutAutoElement(super.widget);

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    (renderObject as FigmaFrameLayoutAutoRenderBox).element = this;
  }

  Element findChildElement(RenderObject child) {
    return children.firstWhere((e) => e.renderObject == child);
  }
}

class FigmaFrameLayoutAutoRenderBox extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, FigmaFrameLayoutAutoParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, FigmaFrameLayoutAutoParentData>
{
  FigmaDimensionsModel figmaDimensions;
  FigmaLayoutModel figmaLayout;
  FigmaFrameLayoutAutoElement? element;

  FigmaFrameLayoutAutoRenderBox({
    required this.figmaDimensions,
    required this.figmaLayout,
  });

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! FigmaFrameLayoutAutoParentData) {
      child.parentData = FigmaFrameLayoutAutoParentData();
    }
  }

  @override
  void performLayout() {
    final List<RenderBox> children = [];
    final List<RenderBox> absChildren = [];

    var child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as FigmaFrameLayoutAutoParentData;
      if (childParentData.dimensions == null && element != null) {
        final childElement = element!.findChildElement(child);
        if (childElement.widget is FigmaNode) {
          final figmaNode = childElement.widget as FigmaNode;
          childParentData.dimensions = figmaNode.dimensions;
        }
      }

      if (childParentData.dimensions?.positioning == FigmaDimensionsPositioning.absolute) {
        absChildren.add(child);
      } else {
        children.add(child);
      }

      child = childParentData.nextSibling;
    }

    switch (figmaLayout.mode) {
      case FigmaLayoutMode.vertical:
        _performColumnLayout(children, absChildren);
        break;

      case FigmaLayoutMode.horizontal:
        _performRowLayout(children, absChildren);

      default:
        throw UnimplementedError('Unsupported layout mode: ${figmaLayout.mode}');
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  (double, double) _computeChildCrossAxisConstraints(FigmaDimensionsSizing mode, double length, double minLength, double maxLength, double parentLength) {
    double minConstraint = switch(mode) {
      FigmaDimensionsSizing.hug => minLength,
      FigmaDimensionsSizing.fill => min(max(minLength, parentLength), maxLength),
      FigmaDimensionsSizing.fixed => length,
    };

    double maxConstraint = switch(mode) {
      FigmaDimensionsSizing.hug => maxLength,
      FigmaDimensionsSizing.fill => min(max(minLength, parentLength), maxLength),
      FigmaDimensionsSizing.fixed => length,
    };

    return (minConstraint, maxConstraint);
  }

  void _performLayout(List<RenderBox> children, List<RenderBox> absChildren, _AxisGetters axisGetters) {
    double sumMainAxis = 0;
    double maxCrossAxis = 0;
    double gap = figmaLayout.itemSpacing;
    double sumGap = 0;
    final padding = figmaLayout.padding;

    // process children with fixed main axis
    final fixedChildren = children.where((child) {
      final childParentData = child.parentData as FigmaFrameLayoutAutoParentData;
      return axisGetters.mainAxisMode(childParentData.dimensions!) == FigmaDimensionsSizing.fixed;
    });
    for (final child in fixedChildren) {
      final childParentData = child.parentData as FigmaFrameLayoutAutoParentData;
      final childDimensionsSize = Size(childParentData.dimensions!.width, childParentData.dimensions!.height);
      final (crossAxisMin, crossAxisMax) = _computeChildCrossAxisConstraints(
        axisGetters.crossAxisMode(childParentData.dimensions!),
        axisGetters.crossAxis(childDimensionsSize),
        axisGetters.minCrossAxis(childParentData.dimensions!.sizeConstraints),
        axisGetters.maxCrossAxis(childParentData.dimensions!.sizeConstraints),
        axisGetters.maxCrossAxis(constraints),
      );

      final fixedMainAxisSize = axisGetters.mainAxis(childDimensionsSize);
      final childConstraints = axisGetters.makeConstraints(
        // fixed can be assumed here for the main axis
        fixedMainAxisSize,
        fixedMainAxisSize,
        crossAxisMin,
        crossAxisMax,
      );

      child.layout(childConstraints, parentUsesSize: true);
      sumMainAxis += axisGetters.mainAxis(child.size);
      maxCrossAxis = max(maxCrossAxis, axisGetters.crossAxis(child.size));
      sumGap += gap;
    }

    // process children with hug main axis
    final hugChildren = children.where((child) {
      final childParentData = child.parentData as FigmaFrameLayoutAutoParentData;
      return axisGetters.mainAxisMode(childParentData.dimensions!) == FigmaDimensionsSizing.hug;
    });
    for (final child in hugChildren) {
      final childParentData = child.parentData as FigmaFrameLayoutAutoParentData;
      final childDimensionsSize = Size(childParentData.dimensions!.width, childParentData.dimensions!.height);
      final (crossAxisMin, crossAxisMax) = _computeChildCrossAxisConstraints(
        axisGetters.crossAxisMode(childParentData.dimensions!),
        axisGetters.crossAxis(childDimensionsSize),
        axisGetters.minCrossAxis(childParentData.dimensions!.sizeConstraints),
        axisGetters.maxCrossAxis(childParentData.dimensions!.sizeConstraints),
        axisGetters.maxCrossAxis(constraints),
      );

      final childConstraints = axisGetters.makeConstraints(
        axisGetters.minMainAxis(childParentData.dimensions!.sizeConstraints),
        axisGetters.maxMainAxis(childParentData.dimensions!.sizeConstraints),
        crossAxisMin,
        crossAxisMax,
      );

      child.layout(childConstraints, parentUsesSize: true);
      sumMainAxis += axisGetters.mainAxis(child.size);
      maxCrossAxis = max(maxCrossAxis, axisGetters.crossAxis(child.size));
      sumGap += gap;
    }

    // process children with fill main axis
    final fillChildren = children.where((child) {
      final childParentData = child.parentData as FigmaFrameLayoutAutoParentData;
      return axisGetters.mainAxisMode(childParentData.dimensions!) == FigmaDimensionsSizing.fill;
    });
    if (fillChildren.isNotEmpty) {
      final (flexSumMainAxis, flexMaxCrossAxis, flexSumGap) = _performFlexLayout(
        fillChildren.toList(),
        sumMainAxis,
        sumGap,
        gap,
        axisGetters,
      );
      sumMainAxis += flexSumMainAxis;
      maxCrossAxis = max(maxCrossAxis, flexMaxCrossAxis);
      sumGap += flexSumGap;
    }

    // subtract one from the gap sum to account for the last item
    if (sumGap > 0) {
      sumGap -= gap;
    }

    double mainAxisLength;
    double crossAxisLength;

    switch (axisGetters.mainAxisMode(figmaDimensions)) {
      case FigmaDimensionsSizing.hug:
        mainAxisLength = max(min(sumMainAxis + sumGap, axisGetters.maxMainAxis(constraints)), axisGetters.minMainAxis(constraints));
        break;

      case FigmaDimensionsSizing.fixed:
      case FigmaDimensionsSizing.fill:
        mainAxisLength = axisGetters.maxMainAxis(constraints);
        break;
    }

    switch (axisGetters.crossAxisMode(figmaDimensions)) {
      case FigmaDimensionsSizing.hug:
        crossAxisLength = max(min(maxCrossAxis, axisGetters.maxCrossAxis(constraints)), axisGetters.minCrossAxis(constraints));
        break;

      case FigmaDimensionsSizing.fill:
      case FigmaDimensionsSizing.fixed:
        crossAxisLength = axisGetters.maxCrossAxis(constraints);
        break;
    }

    if (constraints.isTight) {
      size = constraints.biggest;
    } else {
      size = axisGetters.makeSize(mainAxisLength, crossAxisLength);
    }

    // position children
    double mainAxisOffset = 0;
    for (var i = 0, n = children.length; i < n; ++i) {
      final child = children[i];
      final childParentData = child.parentData as FigmaFrameLayoutAutoParentData;
      final childMainAxisLength = axisGetters.mainAxis(child.size);
      final childCrossAxisLength = axisGetters.crossAxis(child.size);
      final selfMainAxisLength = axisGetters.mainAxis(size);
      final selfCrossAxisLength = axisGetters.crossAxis(size);

      double crossAxis = switch (figmaLayout.crossAxisAlignItems) {
        FigmaLayoutAxisAlignItems.start => 0,
        FigmaLayoutAxisAlignItems.center => (selfCrossAxisLength - childCrossAxisLength) / 2,
        FigmaLayoutAxisAlignItems.end => selfCrossAxisLength - childCrossAxisLength,
        _ => 0, // unsupported for now
      };

      double mainAxisStart = switch(figmaLayout.mainAxisAlignItems) {
        FigmaLayoutAxisAlignItems.start => 0,
        FigmaLayoutAxisAlignItems.center => (selfMainAxisLength - sumMainAxis - sumGap) / 2,
        FigmaLayoutAxisAlignItems.end => selfMainAxisLength - sumMainAxis - sumGap,
        FigmaLayoutAxisAlignItems.spaceBetween => 0,
        _ => 0, // unsupported for now
      };

      if (figmaLayout.mainAxisAlignItems == FigmaLayoutAxisAlignItems.spaceBetween) {
        if (n > 1) {
          gap = (selfMainAxisLength - sumMainAxis) / (n - 1);
        } else {
          mainAxisStart = (selfMainAxisLength - sumMainAxis) / 2;
        }
      }

      childParentData.offset = axisGetters.makeOffset(mainAxisStart + mainAxisOffset, crossAxis);
      mainAxisOffset += childMainAxisLength + gap;
    }

    for (final child in absChildren) {
      final childParentData = child.parentData as FigmaFrameLayoutAutoParentData;
      final parentSize = size + Offset(padding.left + padding.right, padding.top + padding.bottom);
      Rect rect = computeChildExportRect(figmaDimensions, childParentData.dimensions!);
      Rect childRect = computeChildLayoutRect(figmaDimensions, childParentData.dimensions!, parentSize, rect);
      child.layout(BoxConstraints.tight(childRect.size), parentUsesSize: false);
      childParentData.offset = childRect.topLeft - Offset(padding.left, padding.top);
    }
  }

  void _performColumnLayout(List<RenderBox> children, List<RenderBox> absChildren) {
    _performLayout(children, absChildren, _AxisGetters(
      mainAxis: (size) => size.height,
      crossAxis: (size) => size.width,
      minMainAxis: (constraints) => constraints.minHeight,
      minCrossAxis: (constraints) => constraints.minWidth,
      maxMainAxis: (constraints) => constraints.maxHeight,
      maxCrossAxis: (constraints) => constraints.maxWidth,
      mainAxisMode: (dimensions) => dimensions.heightMode,
      crossAxisMode: (dimensions) => dimensions.widthMode,
      makeSize: (double mainAxis, double crossAxis) => Size(crossAxis, mainAxis),
      makeOffset: (double mainAxis, double crossAxis) => Offset(crossAxis, mainAxis),
      makeConstraints: (double minMainAxis, double maxMainAxis, double minCrossAxis, double maxCrossAxis) => BoxConstraints(
        minWidth: minCrossAxis,
        maxWidth: maxCrossAxis,
        minHeight: minMainAxis,
        maxHeight: maxMainAxis,
      ),
    ));
  }

  void _performRowLayout(List<RenderBox> children, List<RenderBox> absChildren) {
    _performLayout(children, absChildren, _AxisGetters(
      mainAxis: (size) => size.width,
      crossAxis: (size) => size.height,
      minMainAxis: (constraints) => constraints.minWidth,
      minCrossAxis: (constraints) => constraints.minHeight,
      maxMainAxis: (constraints) => constraints.maxWidth,
      maxCrossAxis: (constraints) => constraints.maxHeight,
      mainAxisMode: (dimensions) => dimensions.widthMode,
      crossAxisMode: (dimensions) => dimensions.heightMode,
      makeSize: (double mainAxis, double crossAxis) => Size(mainAxis, crossAxis),
      makeOffset: (double mainAxis, double crossAxis) => Offset(mainAxis, crossAxis),
      makeConstraints: (double minMainAxis, double maxMainAxis, double minCrossAxis, double maxCrossAxis) => BoxConstraints(
        minWidth: minMainAxis,
        maxWidth: maxMainAxis,
        minHeight: minCrossAxis,
        maxHeight: maxCrossAxis,
      ),
    ));
  }

  // Algo inspired by: https://github.com/facebook/yoga/blob/main/yoga/algorithm/CalculateLayout.cpp#L861-L882
  //
  // Do two passes over the flex items to figure out how to distribute the
  // remaining space.
  //
  // The first pass finds the items whose min/max constraints trigger, freezes
  // them at those sizes, and excludes those sizes from the remaining space.
  //
  // The second pass sets the size of each flexible item. It distributes the
  // remaining space amongst the items whose min/max constraints didn't trigger in
  // the first pass. For the other items, it sets their sizes by forcing their
  // min/max constraints to trigger again.
  //
  // This two pass approach for resolving min/max constraints deviates from the
  // spec. The spec
  // (https://www.w3.org/TR/CSS-flexbox-1/#resolve-flexible-lengths) describes a
  // process that needs to be repeated a variable number of times. The algorithm
  // implemented here won't handle all cases but it was simpler to implement and
  // it mitigates performance concerns because we know exactly how many passes
  // it'll do.
  //
  // At the end of this function the child nodes would have the proper size
  // assigned to them.
  //
  // returns a tuple with the sum of the main axis, the max size for the
  // cross axis, and the sum of the gaps for this layout
  (double, double, double) _performFlexLayout(
    List<RenderBox> children,
    double sumMainAxis,
    double sumGap,
    double gap,
    _AxisGetters axisGetters,
  ) {
    // compute the desired main axis length
    double availableLength = axisGetters.maxMainAxis(constraints) - sumMainAxis - sumGap - gap * (children.length - 1);
    double fillMainAxisLength = max(0, availableLength / children.length);

    sumMainAxis = 0;
    sumGap = 0;
    double maxCrossAxis = 0;

    // FIRST PASS
    // separate children that do not trigger min/max constraints, layout the
    // ones that do
    final nonTriggeredChildren = <RenderBox>[];
    for (final child in children) {
      final childParentData = child.parentData as FigmaFrameLayoutAutoParentData;
      final minChildConstraint = axisGetters.minMainAxis(childParentData.dimensions!.sizeConstraints);
      final maxChildConstraint = axisGetters.maxMainAxis(childParentData.dimensions!.sizeConstraints);
      if (minChildConstraint <= fillMainAxisLength && maxChildConstraint >= fillMainAxisLength) {
        nonTriggeredChildren.add(child);
        continue;
      }

      final childDimensionsSize = Size(childParentData.dimensions!.width, childParentData.dimensions!.height);
      final (crossAxisMin, crossAxisMax) = _computeChildCrossAxisConstraints(
        axisGetters.crossAxisMode(childParentData.dimensions!),
        axisGetters.crossAxis(childDimensionsSize),
        axisGetters.minCrossAxis(childParentData.dimensions!.sizeConstraints),
        axisGetters.maxCrossAxis(childParentData.dimensions!.sizeConstraints),
        axisGetters.maxCrossAxis(constraints),
      );

      final mainAxisConstraint = min(max(fillMainAxisLength, minChildConstraint), maxChildConstraint);
      final childConstraints = axisGetters.makeConstraints(
        mainAxisConstraint,
        mainAxisConstraint,
        crossAxisMin,
        crossAxisMax,
      );

      child.layout(childConstraints, parentUsesSize: true);
      final childMainAxisLength = axisGetters.mainAxis(child.size);
      sumMainAxis += childMainAxisLength;
      availableLength -= childMainAxisLength;
      maxCrossAxis = max(maxCrossAxis, axisGetters.crossAxis(child.size));
      sumGap += gap;
    }

    // SECOND PASS
    // distribute the remaining space amongst the children that did not trigger
    // min/max constraints
    fillMainAxisLength = max(0, availableLength / nonTriggeredChildren.length);
    for (final child in nonTriggeredChildren) {
      final childParentData = child.parentData as FigmaFrameLayoutAutoParentData;
      final childDimensionsSize = Size(childParentData.dimensions!.width, childParentData.dimensions!.height);
      final (crossAxisMin, crossAxisMax) = _computeChildCrossAxisConstraints(
        axisGetters.crossAxisMode(childParentData.dimensions!),
        axisGetters.crossAxis(childDimensionsSize),
        axisGetters.minCrossAxis(childParentData.dimensions!.sizeConstraints),
        axisGetters.maxCrossAxis(childParentData.dimensions!.sizeConstraints),
        axisGetters.maxCrossAxis(constraints),
      );

      final childConstraints = axisGetters.makeConstraints(
        fillMainAxisLength,
        fillMainAxisLength,
        crossAxisMin,
        crossAxisMax,
      );

      child.layout(childConstraints, parentUsesSize: true);
      sumMainAxis += axisGetters.mainAxis(child.size);
      maxCrossAxis = max(maxCrossAxis, axisGetters.crossAxis(child.size));
      sumGap += gap;
    }

    return (sumMainAxis, maxCrossAxis, sumGap);
  }
}

class _AxisGetters {
  final double Function(Size) mainAxis;
  final double Function(Size) crossAxis;
  final double Function(BoxConstraints) minMainAxis;
  final double Function(BoxConstraints) minCrossAxis;
  final double Function(BoxConstraints) maxMainAxis;
  final double Function(BoxConstraints) maxCrossAxis;
  final FigmaDimensionsSizing Function(FigmaDimensionsModel dimensions) mainAxisMode;
  final FigmaDimensionsSizing Function(FigmaDimensionsModel dimensions) crossAxisMode;
  final Size Function(double, double) makeSize;
  final Offset Function(double, double) makeOffset;
  final BoxConstraints Function(double, double, double, double) makeConstraints;

  _AxisGetters({
    required this.mainAxis,
    required this.crossAxis,
    required this.minMainAxis,
    required this.minCrossAxis,
    required this.maxMainAxis,
    required this.maxCrossAxis,
    required this.mainAxisMode,
    required this.crossAxisMode,
    required this.makeSize,
    required this.makeOffset,
    required this.makeConstraints,
  });
}
