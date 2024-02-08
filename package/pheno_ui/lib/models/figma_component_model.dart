import 'figma_dimensions_model.dart';
import 'figma_layout_model.dart';
import 'figma_node_model.dart';

class FigmaComponentModel extends FigmaNodeModel {
  final String widgetType;
  final FigmaLayoutParentValuesModel parentLayout;
  final Map<String, dynamic> userData;

  FigmaComponentModel.fromJson(Map<String, dynamic> json):
    widgetType = json['widgetType'],
    parentLayout = FigmaLayoutParentValuesModel.fromJson(json['parentLayout']),
    userData = json['__userData'],
    super.fromJson(json);
}