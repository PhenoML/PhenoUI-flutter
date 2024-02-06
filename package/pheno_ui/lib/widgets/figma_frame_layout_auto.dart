import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:pheno_ui/models/figma_layout_model.dart';
import 'package:pheno_ui/parsers/tools/figma_enum.dart';

import '../models/figma_dimensions_model.dart';
import 'figma_node.dart';

List<Widget> _addSpacers(List<Widget> widgets, double width, double height) {
  for (int i = 0, n = max(widgets.length - 1, 0); i < n; ++i) {
    widgets.insert(i * 2 + 1, SizedBox(
      width: width,
      height: height,
    ));
  }
  return widgets;
}

class _FigmaFrameLayoutAutoDelegate extends SingleChildLayoutDelegate {
  final FigmaDimensionsSelfModel dimensions;
  final FigmaLayoutValuesModel layout;
  // final FigmaNode child;

  _FigmaFrameLayoutAutoDelegate({
    required this.dimensions,
    required this.layout,
    // required this.child
  });

  @override
  Size getSize(BoxConstraints constraints) {
    // the scale is computed based on the cross axis
    double scale = switch (layout.mode) {
      FigmaLayoutMode.vertical => constraints.maxWidth / dimensions.width,
      FigmaLayoutMode.horizontal => constraints.maxHeight / dimensions.height,
      _ => throw 'Layout mode ${layout.mode} not supported by auto layout'
    };

    double width = switch (dimensions.widthMode) {
      FigmaDimensionsSizing.fixed => dimensions.width,
      FigmaDimensionsSizing.hug => dimensions.width * scale,
      FigmaDimensionsSizing.fill => double.infinity,
    };

    double height = switch (dimensions.heightMode) {
      FigmaDimensionsSizing.fixed => dimensions.height,
      FigmaDimensionsSizing.hug => dimensions.height * scale,
      FigmaDimensionsSizing.fill => double.infinity,
    };

    // compute the expected size
    return Size(
      width,
      height,
    );
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    // the scale is computed based on the main axis
    double scale = switch (layout.mode) {
      FigmaLayoutMode.vertical => constraints.maxWidth / dimensions.width,
      FigmaLayoutMode.horizontal => constraints.maxHeight / dimensions.height,
      _ => throw 'Layout mode ${layout.mode} not supported by auto layout'
    };

    double minWidth, maxWidth;
    double minHeight, maxHeight;

    switch (dimensions.widthMode) {
      case FigmaDimensionsSizing.fixed:
        minWidth = maxWidth = dimensions.width;
        break;

      case FigmaDimensionsSizing.hug:
        minWidth = 0;
        maxWidth = dimensions.width * scale;
        break;

      case FigmaDimensionsSizing.fill:
        minWidth = constraints.maxWidth;
        maxWidth = double.infinity;
        break;
    }

    switch (dimensions.heightMode) {
      case FigmaDimensionsSizing.fixed:
        minHeight = maxHeight = dimensions.height;
        break;

      case FigmaDimensionsSizing.hug:
        minHeight = 0;
        maxHeight = dimensions.height * scale;
        break;

      case FigmaDimensionsSizing.fill:
        minHeight = constraints.maxHeight;
        maxHeight = double.infinity;
        break;
    }

    return BoxConstraints(
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset.zero;
  }

  @override
  bool shouldRelayout(covariant SingleChildLayoutDelegate oldDelegate) {
    // TODO: implement shouldRelayout
    return true;
  }
}

class FigmaFrameLayoutAuto extends StatelessWidget {
  final FigmaDimensionsSelfModel dimensions;
  final FigmaLayoutValuesModel layout;
  final List<Widget> children;

  const FigmaFrameLayoutAuto._create({
    required this.dimensions,
    required this.layout,
    required this.children,
    super.key
  });

  factory FigmaFrameLayoutAuto({
    required FigmaDimensionsSelfModel dimensions,
    required FigmaLayoutValuesModel layout,
    required List<Widget> children
  }) {
    if (layout.itemSpacing != 0) {
      switch (layout.mode) {
        case FigmaLayoutMode.vertical:
          children = _addSpacers(children, 0.0, layout.itemSpacing);
          break;

        case FigmaLayoutMode.horizontal:
          children = _addSpacers(children, layout.itemSpacing, 0.0);
          break;

        default:
          throw 'Layout mode ${layout.mode} not supported by auto layout';
      }
    }
    return FigmaFrameLayoutAuto._create(
      dimensions: dimensions,
      layout: layout,
      children: children
    );
  }

  Widget _buildVertical(BuildContext context, BoxConstraints constraints) {
    // scale is computed based on the cross axis
    double scale = constraints.maxWidth / dimensions.width;
    double maxSize = constraints.maxHeight;
    double usedSize = children.fold(0, (previousValue, element) {
      if (element is FigmaNode) {
        // scale is computed based on the cross axis
        var localScale = element.dimensions!.heightMode == FigmaDimensionsSizing.fixed ? 1.0 : scale;
        return previousValue + element.dimensions!.height * localScale;
      } else if (element is SizedBox) {
        return previousValue + element.height!;
      }
      return previousValue;
    });

    double expandable = children.where((e) => e is FigmaNode && e.dimensions!.heightMode == FigmaDimensionsSizing.fill).length.toDouble();
    double expandableSize = (maxSize - usedSize) / expandable;

    List <Widget> renderChildren = children.map((child) {
      if (child is! FigmaNode) {
        return child;
      }

      Widget wrapped = child;
      if (child.dimensions!.heightMode == FigmaDimensionsSizing.hug) {
        wrapped = UnconstrainedBox(
          constrainedAxis: Axis.vertical,
          child: wrapped,
        );
      } else {
        wrapped = CustomSingleChildLayout(
          delegate: _FigmaFrameLayoutAutoDelegate(
            dimensions: child.dimensions!,
            layout: layout,
            // child: child
          ),
          child: wrapped,
        );
      }

      if (child.dimensions!.heightMode == FigmaDimensionsSizing.fill) {
        if (child.dimensions!.sizeConstraints.hasBoundedWidth) {
          var localScale = child.dimensions!.widthMode == FigmaDimensionsSizing.fixed ? 1.0 : scale;
          wrapped = SizedBox(
            height: expandableSize.clamp(
              child.dimensions!.sizeConstraints.minHeight * localScale,
              child.dimensions!.sizeConstraints.maxHeight * localScale
            ),
            child: wrapped,
          );
        } else {
          wrapped = Expanded(
            child: wrapped,
          );
        }
      }

      return wrapped;
    }).toList();

    return Column(
      mainAxisAlignment: MainAxisAlignment.values.convertDefault(layout.mainAxisAlignItems, MainAxisAlignment.start),
      crossAxisAlignment: CrossAxisAlignment.values.convertDefault(layout.crossAxisAlignItems, CrossAxisAlignment.start),
      children: renderChildren,
    );
  }

  Widget _buildHorizontal(BuildContext context, BoxConstraints constraints) {
    // scale is computed based on the cross axis
    double scale = constraints.maxHeight / dimensions.height;
    double maxSize = constraints.maxWidth;
    double usedSize = children.fold(0, (previousValue, element) {
      if (element is FigmaNode) {
        // scale is computed based on the cross axis
        var localScale = element.dimensions!.widthMode == FigmaDimensionsSizing.fixed ? 1.0 : scale;
        return previousValue + element.dimensions!.width * localScale;
      } else if (element is SizedBox) {
        return previousValue + element.width!;
      }
      return previousValue;
    });

    double expandable = children.where((e) => e is FigmaNode && e.dimensions!.widthMode == FigmaDimensionsSizing.fill).length.toDouble();
    double expandableSize = (maxSize - usedSize) / expandable;

    List<Widget> renderChildren = children.map((child) {
      if (child is! FigmaNode) {
        return child;
      }
      Widget wrapped = CustomSingleChildLayout(
        delegate: _FigmaFrameLayoutAutoDelegate(
          dimensions: child.dimensions!,
          layout: layout,
          // child: child
        ),
        child: child,
      );

      if (child.dimensions!.widthMode == FigmaDimensionsSizing.fill) {
        if (child.dimensions!.sizeConstraints.hasBoundedHeight) {
          var localScale = child.dimensions!.heightMode == FigmaDimensionsSizing.fixed ? 1.0 : scale;
          wrapped = SizedBox(
            width: expandableSize.clamp(
                child.dimensions!.sizeConstraints.minWidth * localScale,
                child.dimensions!.sizeConstraints.maxWidth * localScale
            ),
            child: wrapped,
          );
        } else {
          wrapped = Expanded(
            child: wrapped,
          );
        }
      }

      return wrapped;
    }).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.values.convertDefault(layout.mainAxisAlignItems, MainAxisAlignment.start),
      crossAxisAlignment: CrossAxisAlignment.values.convertDefault(layout.crossAxisAlignItems, CrossAxisAlignment.start),
      children: renderChildren,
    );
  }

  Widget _buildWrap(BuildContext context, BoxConstraints constraints) {
    throw 'Wrap layout not implemented';
  }

  @override
  Widget build(BuildContext context) {
    var builder = switch (layout.mode) {
      FigmaLayoutMode.vertical => _buildVertical,
      FigmaLayoutMode.horizontal => layout.wrap == FigmaLayoutWrap.wrap ? _buildWrap : _buildHorizontal,
      _ => throw 'Layout mode ${layout.mode} not implemented'
    };
    return LayoutBuilder(
      builder: builder,
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double maxHeight = constraints.maxHeight - layout.itemSpacing * (children.length - 1);
        double expandable = children.where((e) => e is FigmaNode && e.dimensions!.widthMode == FigmaDimensionsSizing.fill).length.toDouble();
        double expandableHeight = maxHeight / expandable;

        List<Widget> renderChildren = [];

        for (Widget child in children) {
          if (child is! FigmaNode) {
            // this should be a spacer
            renderChildren.add(child);
            continue;
          }

          if (child.dimensions!.widthMode == FigmaDimensionsSizing.fixed && child.dimensions!.heightMode == FigmaDimensionsSizing.fixed) {
            renderChildren.add(
              SizedBox(
                width: child.dimensions!.width,
                height: child.dimensions!.height,
                child: OverflowBox(
                    maxWidth: child.dimensions!.width,
                    maxHeight: child.dimensions!.height,
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: child.dimensions!.width,
                      height: child.dimensions!.height,
                      child: child,
                    )
                ),
              ));
            continue;
          }

          Widget renderChild;
          switch (child.dimensions!.widthMode) {
            case FigmaDimensionsSizing.fixed:
              renderChild = SizedBox(
                width: child.dimensions!.width,
                child: child,
              );
              break;

            case FigmaDimensionsSizing.hug:
              renderChild = UnconstrainedBox(
                constrainedAxis: Axis.horizontal,
                child: child,
              );
              break;

            case FigmaDimensionsSizing.fill:
              renderChild = child;
              break;
          }

          switch (child.dimensions!.heightMode) {
            case FigmaDimensionsSizing.fixed:
              renderChildren.add(SizedBox(
                height: child.dimensions!.height,
                child: child,
              ));
              break;

            case FigmaDimensionsSizing.hug:
              renderChildren.add(UnconstrainedBox(
                constrainedAxis: Axis.vertical,
                child: renderChild,
              ));
              break;

            case FigmaDimensionsSizing.fill:
              if (child.dimensions!.sizeConstraints.hasBoundedWidth) {
                renderChildren.add(SizedBox(
                  height: expandableHeight.clamp(child.dimensions!.sizeConstraints.minHeight, child.dimensions!.sizeConstraints.maxHeight),
                  child: renderChild,
                ));
              } else {
                renderChildren.add(Expanded(
                  child: renderChild,
                ));
              }
          }
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.values.convertDefault(layout.mainAxisAlignItems, MainAxisAlignment.start),
          crossAxisAlignment: CrossAxisAlignment.values.convertDefault(layout.crossAxisAlignItems, CrossAxisAlignment.start),
          children: renderChildren,
        );
      }
    );
  }
}