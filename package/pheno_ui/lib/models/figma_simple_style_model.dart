import 'package:pheno_ui/models/figma_parent_layout_model.dart';
import 'figma_style_model.dart';

class FigmaSimpleStyleModel extends FigmaParentLayoutModel {
  @override
  FigmaStyleModel get style => super.style!;

  FigmaSimpleStyleModel.fromJson(Map<String, dynamic> json):
        super.fromJson(json);
}