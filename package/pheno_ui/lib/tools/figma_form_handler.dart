import 'dart:async';
import 'package:flutter/widgets.dart';

import '../tools/figma_enum.dart';
import '../animation/transition_animation.dart';
import '../interface/route_arguments.dart';
import '../widgets/figma_form.dart';
import 'figma_form_types.dart';
import 'figma_user_data.dart';

typedef FigmaFormRouteHandler = void Function(String route, RouteArguments arguments);

abstract class FigmaFormHandler {
  const FigmaFormHandler();

  bool shouldDisplayInput(String id) => true;

  FutureOr<T?> initialValueForInputID<T>(
    BuildContext context,
    String id
  ) => null;

  void onInit(FigmaFormState state) { /* nothing */ }
  void onDispose(FigmaFormState state) { /* nothing */ }

  void onInputRegistered<T>(
    BuildContext context,
    Map<String, FigmaFormInput> inputs,
    FigmaFormInput<T> input
  ) { /* nothing */ }

  void onInputValueChanged<T>(
    BuildContext context,
    Map<String, FigmaFormInput> inputs,
    FigmaFormInput<T> input
  ) { /* nothing */ }

  void onInputEditingComplete<T>(
    BuildContext context,
    Map<String, FigmaFormInput> inputs,
    FigmaFormInput<T> input
  ) { /* nothing */ }

  void onInputSubmitted<T>(
    BuildContext context,
    Map<String, FigmaFormInput> inputs,
    FigmaFormInput<T> input
  ) { /* nothing */ }

  void onSubmit(
    BuildContext context,
    Map<String, FigmaFormInput> inputs,
    FigmaUserData userData,
    String buttonId,
    Map<String, dynamic>? buttonData
  );

  static bool handleDefaultButtonNavigation(
    NavigatorState navigator,
    FigmaUserData userData,
    Map<String, dynamic>? buttonData,
    {
      FigmaFormRouteHandler? routeHandler,
    }
  ) {
    if (buttonData != null && buttonData.containsKey('route')) {
      RouteType type = RouteType.values.byNameDefault(buttonData['type'], RouteType.screen);
      String? transitionName = buttonData['transition'];

      var arguments = RouteArguments(
        type: type,
        transition: TransitionLibrary.getTransition(transitionName, type),
        data: userData.maybeGet('data'),
      );

      if (routeHandler != null) {
        routeHandler(buttonData['route']!, arguments);
      } else {
        switch (buttonData['action']) {
          case 'pop':
            navigator.pop(arguments.data);
            break;

          case 'push':
            navigator.pushNamed(buttonData['route']!, arguments: arguments);
            break;

          case 'replace':
            navigator.pushReplacementNamed(
                buttonData['route']!, arguments: arguments);
            break;

          default:
            if (arguments.type == RouteType.popup) {
              navigator.pushNamed(
                  buttonData['route']!,
                  arguments: arguments
              );
            } else {
              navigator.pushReplacementNamed(
                  buttonData['route']!,
                  arguments: arguments
              );
            }
        }
      }
      return true;
    }
    return false;
  }
}
