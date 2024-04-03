import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:lottie/src/composition.dart'; // ignore: implementation_imports
import 'package:pheno_ui/parsers/tools/figma_dimensions.dart';

import '../models/figma_lottie_animation_model.dart';
import '../pheno_ui.dart';
import '../widgets/figma_node.dart';

class FigmaLottieAnimationParser extends MiraiParser<FigmaLottieAnimationModel> {
  const FigmaLottieAnimationParser();

  @override
  FigmaLottieAnimationModel getModel(Map<String, dynamic> json) =>
      FigmaLottieAnimationModel.fromJson(json);

  @override
  String get type => 'figma-lottie-animation';

  @override
  Widget parse(BuildContext context, FigmaLottieAnimationModel model) {
    final bytes = utf8.encode(model.animation);

    Widget widget = Lottie.memory(
      bytes,
      fit: BoxFit.cover,
      animate: model.autoplay,
      repeat: model.loop,
      onLoaded: (composition) {
        var params = CompositionParameters.forComposition(composition);
        params.startFrame = model.from.toDouble();
        params.endFrame = model.to.toDouble();
      },
    );

    // Widget widget = Lottie.asset(
    //   'assets/min_pa_anim_sym_unlocked02.json',
    //   fit: BoxFit.cover,
    // );


    widget = FigmaNode.withContext(context,
      model: model,
      child: widget,
    );

    return dimensionWrapWidget(widget, model.dimensions!, model.parentLayout!);
  }
}