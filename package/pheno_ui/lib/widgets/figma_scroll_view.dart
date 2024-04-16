import 'package:flutter/widgets.dart';
import 'package:pheno_ui/models/figma_node_model.dart';
import 'package:pheno_ui/models/figma_simple_child_model.dart';
import 'package:pheno_ui/widgets/figma_node.dart';

class FigmaScrollView extends StatelessFigmaNode<FigmaSimpleChildModel> {
  const FigmaScrollView({ required super.model, super.key });

  static FigmaScrollView fromJson(Map<String, dynamic> json) {
    final FigmaSimpleChildModel model = FigmaSimpleChildModel.fromJson(json);
    return FigmaScrollView(model: model);
  }

  @override
  Widget buildFigmaNode(BuildContext context) {
    return SingleChildScrollView(
      child: model.child,
    );
  }
}