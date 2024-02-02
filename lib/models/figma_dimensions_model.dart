import 'package:flutter/material.dart';
import '../parsers/tools/figma_enum.dart';

/// This property is applicable only for direct children of auto-layout frames.
/// Determines whether a layer's size and position should be determined by
/// auto-layout settings or manually adjustable.
enum FigmaDimensionsPositioning with FigmaEnum {
  auto('AUTO'),
  absolute('ABSOLUTE'),
  ;
  @override
  get figmaName => _figmaName;
  final String? _figmaName;
  const FigmaDimensionsPositioning([this._figmaName]);
}

/// Applicable only on auto-layout frames, their children, and text nodes. This
/// is a shorthand for setting layoutGrow, layoutAlign, primaryAxisSizingMode,
/// and counterAxisSizingMode. This field maps directly to the "Horizontal
/// sizing" dropdown in the Figma UI.
enum FigmaDimensionsSizing with FigmaEnum {
  fixed('FIXED'),
  hug('HUG'),
  fill('FILL'),
  ;
  @override
  get figmaName => _figmaName;
  final String? _figmaName;
  const FigmaDimensionsSizing([this._figmaName]);
}

/// The possible values of the resizing behavior of a layer when its containing frame is resized. In the UI, these are referred to as:
///     "MIN": Left or Top
///     "MAX": Right or Bottom
///     "CENTER": Center
///     "STRETCH": Left & Right or Top & Bottom
///     "SCALE": Scale
enum FigmaDimensionsConstraintType with FigmaEnum {
  min('MIN'),
  max('MAX'),
  center('CENTER'),
  stretch('STRETCH'),
  scale('SCALE'),
  ;
  @override
  get figmaName => _figmaName;
  final String? _figmaName;
  const FigmaDimensionsConstraintType([this._figmaName]);
}

class FigmaDimensionsConstraints {
  final FigmaDimensionsConstraintType horizontal;
  final FigmaDimensionsConstraintType vertical;

  FigmaDimensionsConstraints({
    required this.horizontal,
    required this.vertical
  });

  factory FigmaDimensionsConstraints.fromJson(Map<String, dynamic> json) {
    return FigmaDimensionsConstraints(
      horizontal: FigmaDimensionsConstraintType.values.byNameDefault(json['horizontal'], FigmaDimensionsConstraintType.min),
      vertical: FigmaDimensionsConstraintType.values.byNameDefault(json['vertical'], FigmaDimensionsConstraintType.min),
    );
  }
}

class FigmaDimensionsParentModel {
  final double x;
  final double y;
  final double width;
  final double height;

  FigmaDimensionsParentModel({
    required this.x,
    required this.y,
    required this.width,
    required this.height
  });

  FigmaDimensionsParentModel._fromJson(Map<String, dynamic> json):
    x = json['x'].toDouble(),
    y = json['y'].toDouble(),
    width = json['width'].toDouble(),
    height = json['height'].toDouble();

  factory FigmaDimensionsParentModel.fromJson(Map<String, dynamic> json) =>
    FigmaDimensionsParentModel._fromJson(json);
}

class FigmaDimensionsSelfModel extends FigmaDimensionsParentModel {
  final FigmaDimensionsPositioning positioning;
  final BoxConstraints sizeConstraints;
  final FigmaDimensionsSizing widthMode;
  final FigmaDimensionsSizing heightMode;
  final double rotation;
  final FigmaDimensionsConstraints constraints;

  FigmaDimensionsSelfModel._fromJson(super.json):
    positioning = FigmaDimensionsPositioning.values.byNameDefault(json['positioning'], FigmaDimensionsPositioning.auto),
    sizeConstraints = _parseSizeConstraints(json),
    widthMode = FigmaDimensionsSizing.values.byNameDefault(json['widthMode'], FigmaDimensionsSizing.fixed),
    heightMode = FigmaDimensionsSizing.values.byNameDefault(json['heightMode'], FigmaDimensionsSizing.fixed),
    rotation = json['rotation'].toDouble(),
    constraints = FigmaDimensionsConstraints.fromJson(json['constraints']),
    super._fromJson();

  factory FigmaDimensionsSelfModel.fromJson(Map<String, dynamic> json) =>
    FigmaDimensionsSelfModel._fromJson(json);

  static BoxConstraints _parseSizeConstraints(Map<String, dynamic> json) {
    return BoxConstraints(
      minWidth: json['min']['width']?.toDouble() ?? 0.0,
      minHeight: json['min']['height']?.toDouble() ?? 0.0,
      maxWidth: json['max']['width']?.toDouble() ?? double.infinity,
      maxHeight: json['max']['height']?.toDouble() ?? double.infinity,
    );
  }
}

class FigmaDimensionsModel {
  final FigmaDimensionsSelfModel self;
  final FigmaDimensionsParentModel? parent;

  FigmaDimensionsModel({
    required this.self,
    this.parent
  });

  factory FigmaDimensionsModel.fromJson(Map<String, dynamic> json) {
    var r =  FigmaDimensionsModel(
      self: FigmaDimensionsSelfModel.fromJson(json['self']),
      parent: json['parent']['x'] == null ? null : FigmaDimensionsParentModel.fromJson(json['parent']),
    );
    return r;
  }
}