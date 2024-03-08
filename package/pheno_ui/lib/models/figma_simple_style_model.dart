import 'package:pheno_ui/models/figma_parent_layout_model.dart';
import 'figma_style_model.dart';

class FigmaSimpleStyleModel extends FigmaParentLayoutModel {
  final FigmaStyleModel style;

  FigmaSimpleStyleModel.fromJson(Map<String, dynamic> json):
        style = FigmaStyleModel.fromJson(json['style']),
        super.fromJson(json);
}