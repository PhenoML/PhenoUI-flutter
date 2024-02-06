import 'package:flutter/widgets.dart';
import 'package:pheno_ui/models/figma_dimensions_model.dart';
import 'package:pheno_ui/models/figma_node_model.dart';

class FigmaNode extends StatelessWidget {
  final FigmaNodeInfoModel? info;
  final FigmaDimensionsSelfModel? dimensions;
  final Widget? child;

  const FigmaNode({this.info, this.dimensions, this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return child ?? const SizedBox();
  }
}