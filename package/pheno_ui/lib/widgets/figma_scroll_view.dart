import 'package:flutter/widgets.dart';
import '../models/figma_simple_child_model.dart';
import 'stateless_figma_node.dart';
import '../tools/figma_enum.dart';

class FigmaScrollView extends StatelessFigmaNode<FigmaSimpleChildModel> {
  const FigmaScrollView({ required super.model, super.key });

  static FigmaScrollView fromJson(Map<String, dynamic> json) {
    final FigmaSimpleChildModel model = FigmaSimpleChildModel.fromJson(json);
    return FigmaScrollView(model: model);
  }

  @override
  Widget buildFigmaNode(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.values.byNameDefault(model.userData.maybeGet('direction'), Axis.vertical),
      child: model.child,
    );
  }
}