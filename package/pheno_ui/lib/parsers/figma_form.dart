import 'package:flutter/material.dart';
import 'package:mirai/mirai.dart';
import 'package:pheno_ui/models/figma_simple_child_model.dart';
import 'package:pheno_ui/parsers/tools/figma_user_data.dart';

import '../animation/transition_animation.dart';
import '../interface/log.dart';
import '../interface/route_arguments.dart';
import '../models/figma_frame_model.dart';

class FigmaFormParser extends MiraiParser<FigmaSimpleChildModel> {
  const FigmaFormParser();

  @override
  FigmaSimpleChildModel getModel(Map<String, dynamic> json) => FigmaSimpleChildModel.fromJson(json);

  @override
  String get type => 'figma-form';

  @override
  Widget parse(BuildContext context, FigmaSimpleChildModel model) {
    var frameModel = FigmaFrameModel.fromJson(model.child, (context, hasBuilder, builder) {
      var child = hasBuilder ? builder(context) : Builder(builder: builder);
      return FigmaForm(
        userData: model.userData,
        child: child,
      );
    });
    var parser = MiraiRegistry.instance.getParser(model.child['type']);
    return parser?.parse(context, frameModel) ?? const SizedBox();
  }
}

class FigmaFormInput<T> {
  final FocusNode node;
  final String id;
  T value;
  Type get type => value.runtimeType;
  FigmaFormInput(this.node, this.id, this.value);
}

abstract class FigmaFormHandler {
  const FigmaFormHandler();
  bool shouldDisplayInput(String id) => true;
  void onInputRegistered<T>(BuildContext context, Map<String, FigmaFormInput> inputs, FigmaFormInput<T> input) { /* nothing */ }
  void onInputValueChanged<T>(BuildContext context, Map<String, FigmaFormInput> inputs, FigmaFormInput<T> input) { /* nothing */ }
  void onInputEditingComplete<T>(BuildContext context, Map<String, FigmaFormInput> inputs, FigmaFormInput<T> input) { /* nothing */ }
  void onInputSubmitted<T>(BuildContext context, Map<String, FigmaFormInput> inputs, FigmaFormInput<T> input) { /* nothing */ }
  void onSubmit(BuildContext context, Map<String, FigmaFormInput> inputs, FigmaUserData userData, String buttonId, Map<String, dynamic>? buttonData);
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
            onPressed: () => Navigator.pop(context, true),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void onSubmit(BuildContext context, Map<String, FigmaFormInput> inputs, FigmaUserData userData, String buttonId, Map<String, dynamic>? buttonData) {
    for (var input in inputs.values) {
      switch (input.type) {
        case String:
          if (input.value.isEmpty) {
            Map<String, dynamic>? formData = userData.maybeGet('data');
            _showDialog(context, title: formData?['incomplete_title'], content: formData?['incomplete_message']);
            return;
          }
          break;

        case bool:
          if (!input.value) {
            Map<String, dynamic>? formData = userData.maybeGet('data');
            _showDialog(context, title: formData?['incomplete_title'], content: formData?['incomplete_message']);
            return;
          }
          break;

        default:
          break;
      }
    }

    if (buttonData != null && buttonData.containsKey('route')){
      RouteType type = RouteType.screen;
      String? transitionName = userData.maybeGet('transition');

      var arguments = RouteArguments(
        type: type,
        transition: TransitionLibrary.getTransition(transitionName, type),
        data: userData.maybeGet('data'),
      );

      Navigator.of(context).pushReplacementNamed(buttonData['route']!, arguments: arguments);
    }
  }
}

class FigmaForm extends StatefulWidget {
  static Map<String, FigmaFormHandler> handlerRegistry = { '__default__': _DefaultFormHandler() };
  static void registerFormHandler(String id, FigmaFormHandler handler) {
    if (handlerRegistry.containsKey(id)) {
      throw 'Handler with id $id already exists';
    }
    handlerRegistry[id] = handler;
  }

  final FigmaUserData userData;
  final Widget child;

  const FigmaForm({required this.userData, required this.child, Key? key}) : super(key: key);

  @override
  State<FigmaForm> createState() => FigmaFormState();
}

class FigmaFormState extends State<FigmaForm> {
  FigmaFormHandler? handler;
  Map<String, FigmaFormInput> inputs = {};

  @override
  void initState() {
    super.initState();
    var formId = widget.userData.maybeGet('form');
    if (formId == null || !FigmaForm.handlerRegistry.containsKey(formId)) {
      formId = '__default__';
    }
    handler = FigmaForm.handlerRegistry[formId];
  }

  @override
  Widget build(BuildContext context) {
    return FigmaFormInterface(
      shouldDisplayInput: shouldDisplayInput,
      registerInput: registerInput,
      inputValueChanged: inputValueChanged,
      inputEditingComplete: inputEditingComplete,
      inputSubmitted: inputSubmitted,
      submit: submit,
      child: widget.child,
    );
  }

  bool shouldDisplayInput(String id) {
    return handler?.shouldDisplayInput(id) ?? true;
  }

  FocusNode registerInput<T>(String id, T initialValue) {
    if (inputs.containsKey(id)) {
      logger.w('Input with id $id already exists.');
    }
    FocusNode node = FocusNode();
    inputs[id] = FigmaFormInput<T>(node, id, initialValue);
    handler?.onInputRegistered(context, inputs, inputs[id]!);
    return node;
  }

  void inputValueChanged<T>(String id, T value) {
    if (!inputs.containsKey(id)) {
      throw 'Input with id $id does not exist';
    }
    inputs[id]!.value = value;
    handler?.onInputValueChanged(context, inputs, inputs[id]!);
  }

  void inputEditingComplete(String id) {
    if (!inputs.containsKey(id)) {
      throw 'Input with id $id does not exist';
    }
    handler?.onInputEditingComplete(context, inputs, inputs[id]!);
  }

  void inputSubmitted<T>(String id, T value) {
    if (!inputs.containsKey(id)) {
      throw 'Input with id $id does not exist';
    }
    inputs[id]!.value = value;
    handler?.onInputSubmitted(context, inputs, inputs[id]!);
  }

  void submit(String id, Map<String, dynamic>? buttonData) {
    handler?.onSubmit(context, inputs, widget.userData, id, buttonData);
  }
}

class FigmaFormInterface extends InheritedWidget {
  final bool Function(String) shouldDisplayInput;
  final FocusNode Function<T>(String, T) registerInput;
  final void Function<T>(String, T) inputValueChanged;
  final void Function(String) inputEditingComplete;
  final void Function<T>(String, T) inputSubmitted;
  final void Function(String, Map<String, dynamic>?) submit;

  const FigmaFormInterface({
    required this.shouldDisplayInput,
    required this.registerInput,
    required this.inputValueChanged,
    required this.inputEditingComplete,
    required this.inputSubmitted,
    required this.submit,
    required super.child,
    super.key
  });

  static FigmaFormInterface? maybeOf(BuildContext context, { bool listen = true }) {
    if (listen) {
      return context.dependOnInheritedWidgetOfExactType<FigmaFormInterface>();
    }
    return context.getInheritedWidgetOfExactType<FigmaFormInterface>();
  }

  static FigmaFormInterface of(BuildContext context) {
    final FigmaFormInterface? result = maybeOf(context);
    assert(result != null, 'No FigmaForm found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return oldWidget != this;
  }
}