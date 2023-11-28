import 'package:phenoui_flutter/parsers/tools/figma_enum.dart';
import 'figma_dimensions_model.dart';
import 'figma_layout_model.dart';

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

class FigmaImageModel {
  final FigmaImageFormat format;
  final FigmaDimensionsModel dimensions;
  final FigmaLayoutParentValuesModel parentLayout;
  final double opacity;
  final String data;

  FigmaImageModel._fromJson(Map<String, dynamic> json):
      format = FigmaImageFormat.values.byNameDefault(json['format'], FigmaImageFormat.unknown),
      dimensions = FigmaDimensionsModel.fromJson(json['dimensions']),
      parentLayout = FigmaLayoutParentValuesModel.fromJson(json['parentLayout']),
      opacity = json['opacity'].toDouble(),
      data = json['data'];

  factory FigmaImageModel.fromJson(Map<String, dynamic> json) =>
      FigmaImageModel._fromJson(json);
}