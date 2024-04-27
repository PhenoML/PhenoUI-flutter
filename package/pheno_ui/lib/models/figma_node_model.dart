import 'package:pheno_ui/models/figma_effects_model.dart';

import '../tools/figma_user_data.dart';
import 'figma_style_model.dart';
import 'figma_dimensions_model.dart';

class FigmaNodeInfoModel {
  final String? name;
  final String? id;

  const FigmaNodeInfoModel({
    required this.name,
    required this.id,
  });

  FigmaNodeInfoModel.fromJson(Map<String, dynamic> json):
    name = json['name'],
    id = json['id'];

  @override
  String toString() {
    return 'FigmaNodeInfoModel(name: $name, id: $id)';
  }
}

class FigmaNodeModel {
  final String type;
  final FigmaNodeInfoModel info;
  final FigmaDimensionsModel? dimensions;
  final FigmaStyleModel? style;
  final FigmaEffectsModel? effects;
  final Map<String, dynamic>? componentRefs;
  final FigmaUserData userData;

  const FigmaNodeModel({
    required this.type,
    required this.userData,
    required this.info,
    this.dimensions,
    this.style,
    this.effects,
    this.componentRefs,
  });

  FigmaNodeModel.fromJson(Map<String, dynamic> json):
    type = json['type'],
    info = FigmaNodeInfoModel.fromJson(json['__info']),
    dimensions = json.containsKey('dimensions') ? FigmaDimensionsModel.fromJson(json['dimensions']) : null,
    style = json.containsKey('style') ? FigmaStyleModel.fromJson(json['style']) : null,
    effects = json.containsKey('effects') ? FigmaEffectsModel.fromJson(json['effects']) : null,
    componentRefs = json['componentRefs'],
    userData = FigmaUserData(json['__userData'])
  ;
}