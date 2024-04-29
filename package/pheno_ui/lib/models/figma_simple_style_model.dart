import '../models/figma_node_model.dart';
import 'figma_style_model.dart';

class FigmaSimpleStyleModel extends FigmaNodeModel {
  final FigmaStyleModel style;

  FigmaSimpleStyleModel.fromJson(Map<String, dynamic> json):
      style = FigmaStyleModel.fromJson(json['style']),
      super.fromJson(json);
}