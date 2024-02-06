import 'figma_node_model.dart';

class FigmaSimpleChildModel extends FigmaNodeModel {
  final Map<String, dynamic> child;

  FigmaSimpleChildModel.fromJson(Map<String, dynamic> json):
      child = json['child'] as Map<String, dynamic>,
      super.fromJson(json);
}