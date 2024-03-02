import 'package:flutter/widgets.dart';

import '../models/figma_dimensions_model.dart';
import '../models/figma_frame_model.dart';
import '../models/figma_simple_child_model.dart';
import '../pheno_ui.dart';

class FigmaKeepAspectRatioParser extends MiraiParser<FigmaSimpleChildModel> {
  const FigmaKeepAspectRatioParser();

  @override
  FigmaSimpleChildModel getModel(Map<String, dynamic> json) => FigmaSimpleChildModel.fromJson(json);

  @override
  String get type => 'figma-keep-aspect-ratio';

  @override
  Widget parse(BuildContext context, FigmaSimpleChildModel model) {
    var dimensions = FigmaDimensionsModel.fromJson(model.child['dimensions']);
    print('dimensions: ${model.child['dimensions']}e');
    var frameModel = FigmaFrameModel.fromJson(model.child, (context, hasBuilder, builder) {
      var child = builder(context);
      return Align(
        alignment: Alignment.center,
        child: AspectRatio(
          aspectRatio: dimensions.self.width / dimensions.self.height,
          child: child
        ),
      );
    });
    var parser = MiraiRegistry.instance.getParser(model.child['type']);
    return parser?.parse(context, frameModel) ?? const SizedBox();
  }
}