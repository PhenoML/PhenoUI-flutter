

import 'package:phenoui_flutter/models/figma_layout_model.dart';
import 'package:phenoui_flutter/models/figma_style_model.dart';

import 'figma_dimensions_model.dart';

class FigmaFrameModel {
  FigmaDimensionsModel dimensions;
  FigmaStyleModel style;
  FigmaLayoutModel layout;
  final List<Map<String, dynamic>> children;

  FigmaFrameModel({
    required this.dimensions,
    required this.style,
    required this.layout,
    required this.children,
  });

  factory FigmaFrameModel.fromJson(Map<String, dynamic> json) {
    return FigmaFrameModel(
      dimensions: FigmaDimensionsModel.fromJson(json['dimensions']),
      style: FigmaStyleModel.fromJson(json['style']),
      layout: FigmaLayoutModel.fromJson(json['layout']),
      children: (json['children'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
          const []
    );
  }
}