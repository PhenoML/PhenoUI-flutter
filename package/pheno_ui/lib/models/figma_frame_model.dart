import 'package:flutter/widgets.dart';

import 'figma_dimensions_model.dart';
import 'figma_layout_model.dart';
import 'figma_node_model.dart';
import 'figma_style_model.dart';

Widget noOpWrapper(BuildContext context, bool hasBuilder, WidgetBuilder builder) => builder(context);
typedef FrameWrapper = Widget Function(BuildContext, bool, WidgetBuilder);

class FigmaFrameModel extends FigmaNodeModel{
  final FigmaLayoutModel layout;
  final List<Map<String, dynamic>> children;
  final FrameWrapper wrapper;

  @override
  FigmaStyleModel get style => super.style!;

  FigmaFrameModel.fromJson(Map<String, dynamic> json, [this.wrapper = noOpWrapper]):
      layout = FigmaLayoutModel.fromJson(json['layout']),
      children = (json['children'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
          const [],
      super.fromJson(json);
}