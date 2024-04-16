import 'package:flutter/material.dart';
import '../parsers/tools/figma_enum.dart';

/// Determines whether this layer uses auto-layout to position its children.
/// Defaults to "NONE".
///
/// Changing this property will cause the position of the children of this layer
/// to change as a side-effect. It also causes the size of this layer to change,
/// since at least one dimension of auto-layout frames is automatically
/// calculated.
///
/// As a consequence, note that if a frame has layoutMode === "NONE", calling
/// layoutMode = "VERTICAL"; layoutMode = "NONE" does not leave the document
/// unchanged. Removing auto-layout from a frame does not restore the children
/// to their original positions.
enum FigmaLayoutMode with FigmaEnum {
  none('NONE'),
  vertical('VERTICAL'),
  horizontal('HORIZONTAL'),
  ;
  @override
  get figmaName => _figmaName;
  final String? _figmaName;
  const FigmaLayoutMode([this._figmaName]);
}

/// Determines whether this layer should use wrapping auto-layout.
/// Defaults to "NO_WRAP".
///
/// This property can only be set on layers with layoutMode === "HORIZONTAL".
/// Setting it on layers without this property will throw an Error.
///
/// This property must be set to "WRAP" in order for the counterAxisSpacing and
/// counterAxisAlignContent properties to be applicable.
enum FigmaLayoutWrap with FigmaEnum {
  noWrap('NO_WRAP'),
  wrap('WRAP'),
  ;
  @override
  get figmaName => _figmaName;
  final String? _figmaName;
  const FigmaLayoutWrap([this._figmaName]);
}

/// Applicable only on auto-layout frames. Determines whether the primary axis
/// has a fixed length (determined by the user) or an automatic length
/// (determined by the layout engine).
///
/// Auto-layout frames have a primary axis, which is the axis that resizes when
/// you add new items into the frame. For example, frames with "VERTICAL"
/// layoutMode resize in the y-axis.
//
//     "FIXED": The primary axis length is determined by the user or plugins,
//              unless the layoutAlign is set to “STRETCH” or layoutGrow is 1.
//     "AUTO": The primary axis length is determined by the size of the
//             children. If set, the auto-layout frame will automatically resize
//             along the counter axis to fit its children.
//
// Note: “AUTO” should not be used in any axes where layoutAlign = “STRETCH” or
// layoutGrow = 1. Either use “FIXED” or disable layoutAlign/layoutGrow.
enum FigmaLayoutAxisSizing with FigmaEnum {
  fixed('FIXED'),
  auto('AUTO'),
  ;
  @override
  get figmaName => _figmaName;
  final String? _figmaName;
  const FigmaLayoutAxisSizing([this._figmaName]);
}

/// Applicable only on auto-layout frames. Determines how the auto-layout
/// frame’s children should be aligned in the given axis direction.
///
/// Changing this property will cause all the children to update their x and y values.
//
//     In horizontal auto-layout frames, “MIN” and “MAX” correspond to left and
//     right respectively.
//     In vertical auto-layout frames, “MIN” and “MAX” correspond to top and
//     bottom respectively.
//     “SPACE_BETWEEN” will cause the children to space themselves evenly along
//     the primary axis, only putting the extra space between the children.
//     "BASELINE" can only be set on horizontal auto-layout frames, and aligns
//     all children along the text baseline.
enum FigmaLayoutAxisAlignItems with FigmaEnum {
  start('MIN'),
  end('MAX'),
  center('CENTER'),
  spaceBetween('SPACE_BETWEEN'),
  baseline('BASELINE'), // not supported in Flutter by default // future Dario, you know what to do!
  ;
  @override
  get figmaName => _figmaName;
  final String? _figmaName;
  const FigmaLayoutAxisAlignItems([this._figmaName]);
}

/// Applicable only on auto-layout frames with layoutWrap set to "WRAP".
/// Determines how the wrapped tracks are spaced out inside of the auto-layout
/// frame.
///
/// Changing this property on a non-wrapping auto-layout frame will throw an
/// error.
///
///     "AUTO": If all children of this auto-layout frame have layoutAlign set
///             to "STRETCH", the tracks will stretch to fill the auto-layout
///             frame. This is like flexbox align-content: stretch. Otherwise,
///             each track will be as tall as the tallest child of the track,
///             and will align based on the value of counterAxisAlignItems.
///             This is like flexbox align-content: start | center | end.
///             counterAxisSpacing is respected when counterAxisAlignContent is
///             set to "AUTO".
///
///     "SPACE_BETWEEN": Tracks are all sized based on the tallest child in the
///             track. The free space within the auto-layout frame is divided up
///             evenly between each track. If the total height of all tracks is
///             taller than the height of the auto-layout frame, the spacing
///             will be 0.
enum FigmaLayoutAxisAlignContent with FigmaEnum {
  auto('AUTO'), // not supported natively // Sorry future Dario
  spaceBetween('SPACE_BETWEEN'),
  ;
  @override
  get figmaName => _figmaName;
  final String? _figmaName;
  const FigmaLayoutAxisAlignContent([this._figmaName]);
}

/// Applicable only on direct children of auto-layout frames. Determines if the
/// layer should stretch along the parent’s counter axis. Defaults to “INHERIT”.
///
/// Changing this property will cause the x, y, size, and relativeTransform
/// properties on this node to change, if applicable (inside an auto-layout
/// frame).
///
///     - Setting "STRETCH" will make the node "stretch" to fill the width of
///       the parent vertical auto-layout frame, or the height of the parent
///       horizontal auto-layout frame excluding the frame's padding.
///     - If the current node is an auto layout frame (e.g. an auto layout frame
///       inside a parent auto layout frame) if you set layoutAlign to “STRETCH”
///       you should set the corresponding axis – either primaryAxisSizingMode
///       or counterAxisSizingMode – to be“FIXED”. This is because
///       an auto-layout frame cannot simultaneously stretch to fill its parent
///       and shrink to hug its children.
///     - Setting "INHERIT" does not "stretch" the node.
enum FigmaLayoutAlign with FigmaEnum {
  min('MIN'),
  center('CENTER'),
  max('MAX'),
  stretch('STRETCH'),
  inherit('INHERIT'),
  ;
  @override
  get figmaName => _figmaName;
  final String? _figmaName;
  const FigmaLayoutAlign([this._figmaName]);
}

/// This property is applicable only for direct children of auto-layout frames.
/// Determines whether a layer's size and position should be determined by
/// auto-layout settings or manually adjustable.
///
/// Changing this property may cause the parent layer's size to change, since it
/// will recalculate as if this child did not exist. It will also change this
/// node's x, y, and relativeTransform properties.
///
///     - The default value of "AUTO" will layout this child according to
///       auto-layout rules.
///     - Setting "ABSOLUTE" will take this child out of auto-layout flow, while
///       still nesting inside the auto-layout frame. This allows explicitly
///       setting x, y, width, and height. "ABSOLUTE" positioned nodes respect
///       constraint settings.
enum FigmaLayoutPositioning with FigmaEnum {
  auto('AUTO'),
  absolute('ABSOLUTE'),
  ;
  @override
  get figmaName => _figmaName;
  final String? _figmaName;
  const FigmaLayoutPositioning([this._figmaName]);
}

class FigmaLayoutModel {
  final FigmaLayoutMode mode;
  final FigmaLayoutWrap wrap;
  final FigmaLayoutAxisSizing mainAxisSizing;
  final FigmaLayoutAxisSizing crossAxisSizing;
  final FigmaLayoutAxisAlignItems mainAxisAlignItems;
  final FigmaLayoutAxisAlignItems crossAxisAlignItems;
  final FigmaLayoutAxisAlignContent crossAxisAlignContent;
  final FigmaLayoutAlign align;
  final FigmaLayoutPositioning positioning;
  /// Applicable only on auto-layout frames. Determines the padding between the
  /// border of the frame and its children.
  final EdgeInsets padding;
  /// Applicable only on auto-layout frames. Determines distance between
  /// children of the frame.
  final double itemSpacing;
  /// Applicable only on auto-layout frames with layoutWrap set to "WRAP".
  /// Determines the distance between wrapped tracks. The value must be
  /// positive.
  final double? crossAxisSpacing;
  /// Applicable only on auto-layout frames. Determines the canvas stacking
  /// order of layers in this frame. When true, the first layer will be draw on
  /// top.
  final bool itemReverseZIndex;
  /// Applicable only on auto-layout frames. Determines whether strokes are
  /// included in layout calculations. When true, auto-layout frames behave like
  /// css box-sizing: border-box.
  final bool strokesIncludedInLayout;
  /// This property is applicable only for direct children of auto-layout
  /// frames. Determines whether a layer should stretch along the parent’s
  /// primary axis. 0 corresponds to a fixed size and 1 corresponds to stretch.
  final int grow;

  FigmaLayoutModel._fromJson(Map<String, dynamic> json):
    mode = FigmaLayoutMode.values.byNameDefault(json['layoutMode'], FigmaLayoutMode.none),
    wrap = FigmaLayoutWrap.values.byNameDefault(json['layoutWrap'], FigmaLayoutWrap.noWrap),
    padding = _parsePadding(json),
    mainAxisSizing = FigmaLayoutAxisSizing.values.byNameDefault(json['primaryAxisSizingMode'], FigmaLayoutAxisSizing.fixed),
    crossAxisSizing = FigmaLayoutAxisSizing.values.byNameDefault(json['counterAxisSizingMode'], FigmaLayoutAxisSizing.fixed),
    mainAxisAlignItems = FigmaLayoutAxisAlignItems.values.byNameDefault(json['primaryAxisAlignItems'], FigmaLayoutAxisAlignItems.start),
    crossAxisAlignItems = FigmaLayoutAxisAlignItems.values.byNameDefault(json['counterAxisAlignItems'], FigmaLayoutAxisAlignItems.start),
    crossAxisAlignContent = FigmaLayoutAxisAlignContent.values.byNameDefault(json['counterAxisAlignContent'], FigmaLayoutAxisAlignContent.auto),
    itemSpacing = json['itemSpacing'].toDouble(),
    crossAxisSpacing = json['counterAxisSpacing']?.toDouble(),
    itemReverseZIndex = json['itemReverseZIndex'] ?? false,
    strokesIncludedInLayout = json['strokesIncludedInLayout'] ?? false,
    align = FigmaLayoutAlign.values.byNameDefault(json['layoutAlign'], FigmaLayoutAlign.inherit),
    grow = json['layoutGrow'].toInt(),
    positioning = FigmaLayoutPositioning.values.byNameDefault(json['layoutPositioning'], FigmaLayoutPositioning.auto);

  static EdgeInsets _parsePadding(Map<String, dynamic> json) {
    return EdgeInsets.fromLTRB(
      json['paddingLeft'].toDouble(),
      json['paddingTop'].toDouble(),
      json['paddingRight'].toDouble(),
      json['paddingBottom'].toDouble(),
    );
  }

  static FigmaLayoutModel fromJson(Map<String, dynamic> json) =>
      FigmaLayoutModel._fromJson(json);
}
