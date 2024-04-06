import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:pheno_ui/interface/screens.dart';
import 'package:pheno_ui/models/fimga_image_model.dart';
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
    Widget widget = FigmaLottieAnimation(model: model);

    widget = FigmaNode.withContext(context,
      model: model,
      child: widget,
    );

    return dimensionWrapWidget(widget, model.dimensions!, model.parentLayout!);
  }
}

class FigmaLottieAnimation extends StatefulWidget {
  final FigmaLottieAnimationModel model;

  const FigmaLottieAnimation({
    required this.model,
    super.key,
  });

  @override
  State<FigmaLottieAnimation> createState() => _FigmaLottieAnimationState();
}

class _FigmaLottieAnimationState extends State<FigmaLottieAnimation> with SingleTickerProviderStateMixin {
  LottieComposition? _composition;
  late final AnimationController _controller;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
    );

    _initAsync();
  }

  void _initAsync() async {
    switch (widget.model.method) {
      case FigmaImageDataMethod.embed:
        setState(() {
          _composition = LottieComposition.parseJsonBytes(utf8.encode(widget.model.animation));
          _computeControllerSettings();
        });
        break;

      default:
        final composition = await FigmaScreens().provider!.loadAnimation(widget.model.animation);
        setState(() {
          _composition = composition;
          _computeControllerSettings();
        });
        break;
    }
  }

  void _computeControllerSettings() {
    if (_composition == null) {
      return;
    }

    _controller.duration = _composition!.duration;

    final start = widget.model.from.toDouble() / _composition!.durationFrames;
    final end = widget.model.to.toDouble() / _composition!.durationFrames;

    if (widget.model.autoplay) {
      if (widget.model.loop) {
        _controller.repeat(
          min: start,
          max: end,
          period: _composition!.duration * (end - start),
        );
      } else {
        _controller.value = start;
        _controller.animateTo(
          end,
          duration: _composition!.duration * (end - start)
        );
      }
    } else {
      _controller.value = start;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget widget;
    if (_composition != null) {
      widget = Lottie(
        composition: _composition!,
        controller: _controller,
      );
    } else {
      widget = Container();
    }

    widget = FigmaNode.withContext(context,
      model: this.widget.model,
      child: widget,
    );

    return dimensionWrapWidget(widget, this.widget.model.dimensions!, this.widget.model.parentLayout!);
  }
}