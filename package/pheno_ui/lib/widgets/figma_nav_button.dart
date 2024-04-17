import 'package:flutter/widgets.dart';

import '../tools/figma_enum.dart';
import '../models/figma_nav_button_model.dart';
import '../animation/transition_animation.dart';
import '../interface/route_arguments.dart';
import 'figma_frame.dart';

class FigmaNavButton extends FigmaFrame<FigmaNavButtonModel> {
  const FigmaNavButton({
    required super.childrenContainer,
    required super.model,
    super.key
  });

  static FigmaNavButton fromJson(Map<String, dynamic> json) {
    return figmaFrameFromJson(json, FigmaNavButton.new, FigmaNavButtonModel.fromJson);
  }

  @override
  Widget buildFigmaNode(BuildContext context) {
    Map<String, dynamic>? data = model.userData.maybeGet('data');
    String? screenType = model.userData.maybeGet('screenType');
    var type = RouteType.values.byNameDefault(screenType, RouteType.screen);

    String? transitionName = model.userData.maybeGet('transition');

    var arguments = RouteArguments(
      type: type,
      transition: TransitionLibrary.getTransition(transitionName, type),
      data: data,
    );

    var onTap = switch (model.action) {
      FigmaNavButtonAction.pop => () => Navigator.of(context).pop(data ?? model.target),
      FigmaNavButtonAction.push => () => Navigator.of(context).pushNamed(model.target!, arguments: arguments),
      FigmaNavButtonAction.replace => () => Navigator.of(context).pushReplacementNamed(model.target!, arguments: arguments),
      FigmaNavButtonAction.unknown => throw Exception('Unknown action for FigmaNavButtonModel'),
    };

    return GestureDetector(
        onTap: onTap,
        child: super.buildFigmaNode(context),
    );
  }
}