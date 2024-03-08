import 'package:pheno_ui/models/figma_parent_layout_model.dart';

class FigmaSimpleChildModel extends FigmaParentLayoutModel {
  final Map<String, dynamic> child;

  FigmaSimpleChildModel.fromJson(Map<String, dynamic> json):
      child = json['child'] as Map<String, dynamic>,
      super.fromJson(json);
}