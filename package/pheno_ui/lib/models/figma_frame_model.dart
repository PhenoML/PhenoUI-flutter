import 'package:flutter/widgets.dart';

import 'figma_dimensions_model.dart';
import 'figma_layout_model.dart';
import 'figma_node_model.dart';
import 'figma_style_model.dart';

Widget noOpWrapper(Widget child) => child;
typedef FrameWrapper = Widget Function(Widget);

class FigmaFrameModel extends FigmaNodeModel{
  final String name;
  final FigmaDimensionsModel dimensions;
  final FigmaStyleModel style;
  final FigmaLayoutModel layout;
  final List<Map<String, dynamic>> children;
  final FrameWrapper wrapper;

  FigmaFrameModel.fromJson(Map<String, dynamic> json, [this.wrapper = noOpWrapper]):
      name = json['name'] ?? '',
      dimensions = FigmaDimensionsModel.fromJson(json['dimensions']),
      style = FigmaStyleModel.fromJson(json['style']),
      layout = FigmaLayoutModel.fromJson(json['layout']),
      children = (json['children'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
          const [],
      super.fromJson(json);
}