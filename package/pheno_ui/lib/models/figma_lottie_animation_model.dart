import '../models/figma_node_model.dart';
import '../parsers/tools/figma_enum.dart';
import 'figma_image_model.dart';

class FigmaLottieAnimationModel extends FigmaNodeModel {
  final double opacity;
  final bool autoplay;
  final bool loop;
  late final int from;
  late final int to;
  late final String animation;
  final FigmaImageDataMethod method;

  FigmaLottieAnimationModel.fromJson(Map<String, dynamic> json):
        opacity = json['opacity'].toDouble(),
        method = FigmaImageDataMethod.values.byNameDefault(json['__userData']['method'] ?? json['uploadMethod'], FigmaImageDataMethod.embed),
        autoplay = json['__userData']['autoplay'] ?? false,
        loop = json['__userData']['loop'] ?? false,
        super.fromJson(json) {
    final data = json['__userData']['animation']['fields'];
    animation = data['data'];
    from = data['from'];
    to = data['to'];
  }
}