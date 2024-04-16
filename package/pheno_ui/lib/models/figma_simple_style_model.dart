import '../models/figma_node_model.dart';
import 'figma_style_model.dart';

class FigmaSimpleStyleModel extends FigmaNodeModel {
  @override
  FigmaStyleModel get style => super.style!;

  FigmaSimpleStyleModel.fromJson(Map<String, dynamic> json):
        super.fromJson(json);
}