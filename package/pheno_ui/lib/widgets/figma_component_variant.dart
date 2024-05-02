import 'package:pheno_ui/models/figma_component_variant_model.dart';
import 'package:pheno_ui/widgets/figma_frame.dart';

class FigmaComponentVariant extends FigmaFrame<FigmaComponentVariantModel> {
  Map<String, dynamic> get variantProperties => model.variantProperties;

  const FigmaComponentVariant({
    required super.model,
    super.key
  });

  static FigmaComponentVariant fromJson(Map<String, dynamic> json) {
    return FigmaFrame.fromJson(json, FigmaComponentVariant.new, FigmaComponentVariantModel.fromJson);
  }
}