import 'package:flutter/widgets.dart';

import '../animation/transition_animation.dart';
import '../interface/route_arguments.dart';
import '../models/figma_nav_button_model.dart';
import '../tools/figma_enum.dart';
import 'figma_frame.dart';

class FigmaAutoNavigation extends FigmaFrame {
  const FigmaAutoNavigation({
    required super.model,
    super.key
  });

  static FigmaAutoNavigation fromJson(Map<String, dynamic> json) {
    return FigmaFrame.fromJson(json, FigmaAutoNavigation.new);
  }

  @override
  void onMount(BuildContext context) {
    print('FigmaAutoNavigation.onMount');
    Map<String, dynamic>? data = model.userData.maybeGet('data');
    String? screenType = model.userData.maybeGet('screenType');
    var type = RouteType.values.byNameDefault(screenType, RouteType.screen);

    String? transitionName = model.userData.maybeGet('transition');

    var arguments = RouteArguments(
      type: type,
      transition: TransitionLibrary.getTransition(transitionName, type),
      data: data,
    );

    var action = FigmaNavButtonAction.values.byNameDefault(
        model.userData.maybeGet('action'), FigmaNavButtonAction.unknown
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (action) {
        case FigmaNavButtonAction.pop:
          Navigator.of(context).pop(data ?? model.userData.maybeGet('target'));

        case FigmaNavButtonAction.push:
          Navigator.of(context).pushNamed(model.userData.get('target'), arguments: arguments);

        case FigmaNavButtonAction.replace:
          Navigator.of(context).pushReplacementNamed(model.userData.get('target'), arguments: arguments);

        case FigmaNavButtonAction.unknown:
          throw Exception('Unknown action for FigmaAutoNavigation');
      };
    });
  }
}