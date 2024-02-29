import 'package:pheno_ui/parsers/tools/figma_user_data.dart';
import 'figma_dimensions_model.dart';

class FigmaNodeInfoModel {
  final String? name;
  final String? id;

  FigmaNodeInfoModel.fromJson(Map<String, dynamic> json):
    name = json['name'],
    id = json['id'];
}

class FigmaNodeModel {
  final String type;
  final FigmaNodeInfoModel? info;
  final FigmaDimensionsModel? dimensions;
  final Map<String, dynamic>? componentRefs;
  final FigmaUserData userData;

  FigmaNodeModel.fromJson(Map<String, dynamic> json):
    type = json['type'],
    info = json.containsKey('__info') ? FigmaNodeInfoModel.fromJson(json['__info']) : null,
    dimensions = json.containsKey('dimensions') ? FigmaDimensionsModel.fromJson(json['dimensions']) : null,
    componentRefs = json['componentRefs'],
    userData = FigmaUserData(json['__userData'])
  ;
}