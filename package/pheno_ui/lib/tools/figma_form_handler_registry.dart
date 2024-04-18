import 'package:flutter/material.dart';

import '../animation/transition_animation.dart';
import '../interface/route_arguments.dart';
import 'figma_form_handler.dart';
import 'figma_form_types.dart';
import 'figma_user_data.dart';

class FigmaFormHandlerRegistry {
  final Map<String, FigmaFormHandler> _handlers = {};

  static final FigmaFormHandlerRegistry _instance = FigmaFormHandlerRegistry._internal();
  factory FigmaFormHandlerRegistry() => _instance;
  FigmaFormHandlerRegistry._internal();

  void registerHandler(String key, FigmaFormHandler handler) {
    _handlers[key] = handler;
  }
  FigmaFormHandler getHandler(String? key) {
    return _handlers[key] ?? defaultHandlerInstance();
  }

  FigmaFormHandler defaultHandlerInstance() {
    return _DefaultFormHandler();
  }
}

class _DefaultFormHandler extends FigmaFormHandler {
  void _showDialog(BuildContext context, {String? title, String? content}) {
    showDialog<String>(
      context: context,
      routeSettings: const RouteSettings(name: 'incompleteForm'),
      builder: (BuildContext context) => AlertDialog(
        title: Text(title ?? 'Incomplete Form'),
        content: Text(content ?? 'Please complete the form before submitting.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  bool _fullValidation(BuildContext context, Map<String, FigmaFormInput> inputs, FigmaUserData userData, String buttonId, Map<String, dynamic>? buttonData) {
    for (var input in inputs.values) {
      switch (input.type) {
        case String:
          if (input.value.isEmpty) {
            Map<String, dynamic>? formData = userData.maybeGet('data');
            _showDialog(context, title: formData?['incomplete_title'], content: formData?['incomplete_message']);
            return false;
          }
          break;

        case bool:
          if (!input.value) {
            Map<String, dynamic>? formData = userData.maybeGet('data');
            _showDialog(context, title: formData?['incomplete_title'], content: formData?['incomplete_message']);
            return false;
          }
          break;

        default:
          break;
      }
    }
    return true;
  }

  @override
  void onSubmit(BuildContext context, Map<String, FigmaFormInput> inputs, FigmaUserData userData, String buttonId, Map<String, dynamic>? buttonData) {
    switch(buttonData?['__default_validation__']){
      case 'no_validation':
        break;

      case 'full_validation':
      default:
        if (!_fullValidation(context, inputs, userData, buttonId, buttonData)) {
          return;
        }
        break;
    }

    if (buttonData != null && buttonData.containsKey('route')){
      RouteType type = RouteType.screen;
      String? transitionName = buttonData['transition'];

      var arguments = RouteArguments(
        type: type,
        transition: TransitionLibrary.getTransition(transitionName, type),
        data: userData.maybeGet('data'),
      );

      Navigator.of(context).pushReplacementNamed(buttonData['route']!, arguments: arguments);
    }
  }
}
