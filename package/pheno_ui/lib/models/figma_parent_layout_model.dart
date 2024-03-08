import 'package:pheno_ui/models/figma_node_model.dart';
import 'figma_layout_model.dart';

class FigmaParentLayoutModel extends FigmaNodeModel {
  final FigmaLayoutParentValuesModel? parentLayout;

  FigmaParentLayoutModel.fromJson(Map<String, dynamic> json):
        parentLayout = json.containsKey('parentLayout') ? FigmaLayoutParentValuesModel.fromJson(json['parentLayout']) : null,
        super.fromJson(json);
}