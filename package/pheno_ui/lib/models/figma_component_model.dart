import 'figma_dimensions_model.dart';
import 'figma_layout_model.dart';
import 'figma_node_model.dart';

class FigmaComponentModel extends FigmaNodeModel {
  final String widgetType;
  final FigmaLayoutParentValuesModel parentLayout;

  FigmaComponentModel({
    required this.widgetType,
    required this.parentLayout,
    required super.type,
    required super.userData,
    required super.info,
    super.dimensions,
    super.componentRefs,
  });

  FigmaComponentModel.fromJson(Map<String, dynamic> json):
    widgetType = json['widgetType'],
    parentLayout = FigmaLayoutParentValuesModel.fromJson(json['parentLayout']),
    super.fromJson(json);
}