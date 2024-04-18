import 'figma_node_model.dart';

class FigmaComponentModel extends FigmaNodeModel {
  final String widgetType;

  const FigmaComponentModel({
    required this.widgetType,
    required super.type,
    required super.userData,
    required super.info,
    super.dimensions,
    super.componentRefs,
  });

  FigmaComponentModel._fromJson(Map<String, dynamic> json, { required this.widgetType }):
    super.fromJson(json);

  factory FigmaComponentModel.fromJson(Map<String, dynamic> json) {
    return FigmaComponentModel._fromJson(
        json,
        widgetType: json['widgetType'],
    );
  }
}
