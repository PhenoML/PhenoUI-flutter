import 'package:flutter/material.dart';
import '../parsers/tools/figma_enum.dart';
import 'figma_dimensions_model.dart';
import 'figma_layout_model.dart';
import 'figma_node_model.dart';

enum FigmaImageFormat with FigmaEnum {
  png,
  svg,
  unknown,
  ;
  @override
  get figmaName => _figmaName;
  final String? _figmaName;
  const FigmaImageFormat([this._figmaName]);
}

class FigmaImageModel extends FigmaNodeModel {
  final FigmaImageFormat format;
  final FigmaDimensionsModel dimensions;
  final FigmaLayoutParentValuesModel parentLayout;
  final double opacity;
  final BoxFit fit;
  final String data;

  FigmaImageModel.fromJson(Map<String, dynamic> json):
      format = FigmaImageFormat.values.byNameDefault(json['format'], FigmaImageFormat.unknown),
      dimensions = FigmaDimensionsModel.fromJson(json['dimensions']),
      parentLayout = FigmaLayoutParentValuesModel.fromJson(json['parentLayout']),
      opacity = json['opacity'].toDouble(),
      fit = BoxFit.values.byNameDefault(json['__userData']['scaling'], BoxFit.none),
      data = json['data'],
      super.fromJson(json);
}