import 'dart:ui';
import 'package:pheno_ui/models/figma_simple_child_model.dart';

enum FigmaTileChildHorizontalDirection {
  left,
  center,
  right,
}

enum FigmaTileChildVerticalDirection {
  top,
  center,
  bottom,
}

class FigmaTileChildModel extends FigmaSimpleChildModel {
  final Size childSize;
  final Offset childPosition;
  final FigmaTileChildHorizontalDirection horizontalDirection;
  final FigmaTileChildVerticalDirection verticalDirection;

  FigmaTileChildModel._fromJson({
    required Map<String, dynamic> json,
    required this.childSize,
    required this.childPosition,
    required this.horizontalDirection,
    required this.verticalDirection,
  }): super.fromJson(json);

  factory FigmaTileChildModel.fromJson(Map<String, dynamic> json) {
    var childSize = Size(
      json['child']['dimensions']['width'].toDouble(),
      json['child']['dimensions']['height'].toDouble(),
    );

    var childPosition = Offset(
      json['child']['dimensions']['x'].toDouble(),
      json['child']['dimensions']['y'].toDouble(),
    );

    var horizontal = json['child']['dimensions']['constraints']['horizontal'];
    var vertical = json['child']['dimensions']['constraints']['vertical'];

    var hDirection = horizontal == 'MAX' ? FigmaTileChildHorizontalDirection.left :
      horizontal == 'CENTER' ? FigmaTileChildHorizontalDirection.center :
      FigmaTileChildHorizontalDirection.right;

    var vDirection = vertical == 'MAX' ? FigmaTileChildVerticalDirection.top :
      vertical == 'CENTER' ? FigmaTileChildVerticalDirection.center :
      FigmaTileChildVerticalDirection.bottom;

    return FigmaTileChildModel._fromJson(
      json: json,
      childSize: childSize,
      childPosition: childPosition,
      horizontalDirection: hDirection,
      verticalDirection: vDirection,
    );
  }
}