import 'package:flutter/widgets.dart';
import 'package:pheno_ui/widgets/figma_frame.dart';
import 'package:pheno_ui/widgets/widget_adder.dart';

class WidgetContainer extends FigmaFrame {
  const WidgetContainer({
    required super.model,
    super.key
  });

  static WidgetContainer fromJson(Map<String, dynamic> json) {
    return FigmaFrame.fromJson(json, WidgetContainer.new);
  }

  @override
  Widget buildFigmaNode(BuildContext context) {
    WidgetAdderInherited inherited = WidgetAdder.of(context);
    model.children.clear();
    model.children.addAll(inherited.widgets);
    return super.buildFigmaNode(context);
  }
}