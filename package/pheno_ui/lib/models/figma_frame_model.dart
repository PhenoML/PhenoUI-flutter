import 'package:flutter/widgets.dart';

import 'figma_dimensions_model.dart';
import 'figma_layout_model.dart';
import 'figma_style_model.dart';

Widget noOpWrapper(Widget child) => child;
typedef FrameWrapper = Widget Function(Widget);

class FigmaFrameModel {
  final FigmaDimensionsModel dimensions;
  final FigmaStyleModel style;
  final FigmaLayoutModel layout;
  final List<Map<String, dynamic>> children;
  final FrameWrapper wrapper;

  FigmaFrameModel({
    required this.dimensions,
    required this.style,
    required this.layout,
    required this.children,
    required this.wrapper,
  });

  factory FigmaFrameModel.fromJson(Map<String, dynamic> json, [FrameWrapper wrapper = noOpWrapper]) {
    return FigmaFrameModel(
      dimensions: FigmaDimensionsModel.fromJson(json['dimensions']),
      style: FigmaStyleModel.fromJson(json['style']),
      layout: FigmaLayoutModel.fromJson(json['layout']),
      wrapper: wrapper,
      children: (json['children'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
          const [],
    );
  }
}