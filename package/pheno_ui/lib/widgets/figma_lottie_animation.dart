import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';

import '../interface/screens.dart';
import '../models/figma_image_model.dart';
import '../models/figma_node_model.dart';
import '../models/figma_lottie_animation_model.dart';
import 'stateful_figma_node.dart';

class FigmaLottieAnimation extends StatefulFigmaNode<FigmaLottieAnimationModel> {
  const FigmaLottieAnimation({required super.model, super.key});

  static FigmaLottieAnimation fromJson(Map<String, dynamic> json) {
    final FigmaLottieAnimationModel model = FigmaLottieAnimationModel.fromJson(json);
    return FigmaLottieAnimation(model: model);
  }

  @override
  StatefulFigmaNodeState<StatefulFigmaNode<FigmaNodeModel>> createState() => FigmaLottieAnimationState();
}

class FigmaLottieAnimationState extends StatefulFigmaNodeState<FigmaLottieAnimation> with SingleTickerProviderStateMixin {
  LottieComposition? _composition;
  late final AnimationController _controller = AnimationController(vsync: this);

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
  Widget buildFigmaNode(BuildContext context) {
    if (_composition != null) {
      return Lottie(
        composition: _composition!,
        controller: _controller,
      );
    }

    return Container();
  }
}
