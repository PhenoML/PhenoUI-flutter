import 'figma_frame_model.dart';

class FigmaComponentVariantModel extends FigmaFrameModel {
  final Map<String, dynamic> variantProperties;
  FigmaComponentVariantModel.fromJson(Map<String, dynamic> json):
        variantProperties = json['variantProperties'],
        super.fromJson(json);
}