class FigmaNodeInfoModel {
  final String? name;
  final String? id;

  FigmaNodeInfoModel.fromJson(Map<String, dynamic> json):
    name = json['name'],
    id = json['id'];
}

class FigmaNodeModel {
  final FigmaNodeInfoModel? info;

  FigmaNodeModel.fromJson(Map<String, dynamic> json):
    info = json.containsKey('__info') ? FigmaNodeInfoModel.fromJson(json['__info']) : null;
}