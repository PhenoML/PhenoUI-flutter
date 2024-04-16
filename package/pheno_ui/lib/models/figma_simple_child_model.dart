import 'package:flutter/widgets.dart';
import 'package:pheno_ui/pheno_ui.dart';
import '../models/figma_node_model.dart';

class FigmaSimpleChildModel extends FigmaNodeModel {
  final Widget child;

  FigmaSimpleChildModel.fromJson(Map<String, dynamic> json):
      child = PhenoUi().fromJson(json['child']),
      super.fromJson(json);
}