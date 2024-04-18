import 'package:pheno_ui/pheno_ui.dart';
import '../models/figma_node_model.dart';
import '../widgets/figma_node.dart';

class FigmaSimpleChildModel extends FigmaNodeModel {
  final FigmaNode child;

  FigmaSimpleChildModel.fromJson(Map<String, dynamic> json):
      child = PhenoUi().fromJson(json['child']),
      super.fromJson(json);
}