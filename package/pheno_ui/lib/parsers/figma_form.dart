import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mirai/mirai.dart';
import 'package:pheno_ui/models/figma_simple_child_model.dart';
import 'package:pheno_ui/parsers/tools/figma_user_data.dart';

import '../interface/log.dart';
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
  final String id;
  T value;
  Type get type => value.runtimeType;
  FigmaFormInput(this.id, this.value);
}

abstract class FigmaFormHandler {
  void onInputRegistered<T>(FigmaFormInput<T> input) { /* nothing */ }
  void onInputValueChanged<T>(FigmaFormInput<T> input) { /* nothing */ }
  void onInputEditingComplete<T>(FigmaFormInput<T> input) { /* nothing */ }
  void onInputSubmitted<T>(FigmaFormInput<T> input) { /* nothing */ }
  void onSubmit(BuildContext context, Map<String, FigmaFormInput> inputs, FigmaUserData userData, String? buttonData);
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
            onPressed: () => Navigator.pop(context, 'OK'),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void onSubmit(BuildContext context, Map<String, FigmaFormInput> inputs, FigmaUserData userData, String? buttonData) {
    for (var input in inputs.values) {
      switch (input.type) {
        case String:
          if (input.value.isEmpty) {
            _showDialog(context, content: userData.maybeGet('metadata'));
            return;
          }
          break;

        case bool:
          if (!input.value) {
            _showDialog(context, content: userData.maybeGet('metadata'));
            return;
          }
          break;

        default:
          break;
      }
    }

    if (buttonData != null) {
      Navigator.of(context).pushReplacementNamed(buttonData, arguments: 'screen');
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
      registerInput: registerInput,
      inputValueChanged: inputValueChanged,
      inputEditingComplete: inputEditingComplete,
      inputSubmitted: inputSubmitted,
      submit: submit,
      child: widget.child,
    );
  }

  void registerInput<T>(String id, T initialValue) {
    if (inputs.containsKey(id)) {
      logger.w('Input with id $id already exists.');
      return;
    }
    inputs[id] = FigmaFormInput<T>(id, initialValue);
    handler?.onInputRegistered(inputs[id]!);
  }

  void inputValueChanged<T>(String id, T value) {
    if (!inputs.containsKey(id)) {
      throw 'Input with id $id does not exist';
    }
    inputs[id]!.value = value;
    handler?.onInputValueChanged(inputs[id]!);
  }

  void inputEditingComplete(String id) {
    if (!inputs.containsKey(id)) {
      throw 'Input with id $id does not exist';
    }
    handler?.onInputEditingComplete(inputs[id]!);
  }

  void inputSubmitted<T>(String id, T value) {
    if (!inputs.containsKey(id)) {
      throw 'Input with id $id does not exist';
    }
    inputs[id]!.value = value;
    handler?.onInputSubmitted(inputs[id]!);
  }

  void submit(String? buttonData) {
    handler?.onSubmit(context, inputs, widget.userData, buttonData);
  }
}

class FigmaFormInterface extends InheritedWidget {
  final void Function<T>(String, T) registerInput;
  final void Function<T>(String, T) inputValueChanged;
  final void Function(String) inputEditingComplete;
  final void Function<T>(String, T) inputSubmitted;
  final void Function(String?) submit;

  const FigmaFormInterface({
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