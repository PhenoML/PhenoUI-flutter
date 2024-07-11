import 'package:flutter/widgets.dart';

import '../models/figma_frame_model.dart';
import '../tools/figma_form_handler.dart';
import '../tools/figma_form_handler_registry.dart';
import '../tools/figma_form_types.dart';
import '../interface/log.dart';
import 'figma_frame.dart';
import 'stateful_figma_node.dart';

// while this is effectively a wrapper for a FigmaFrame, it is a special case
// because it is a form and needs to a be a stateful widget, FigmaFrame is
// stateless but exposes all of its important functionality through static
// methods
class FigmaForm extends StatefulFigmaNode<FigmaFrameModel> {
  const FigmaForm({
    required super.model,
    super.key
  });

  static FigmaForm fromJson(Map<String, dynamic> json) {
    return FigmaFrame.fromJson(json, FigmaForm.new);
  }

  static FigmaFormInterface? maybeOf(BuildContext context, { bool listen = true }) {
    if (listen) {
      return context.dependOnInheritedWidgetOfExactType<FigmaFormInterface>();
    }
    return context.getInheritedWidgetOfExactType<FigmaFormInterface>();
  }

  static FigmaFormInterface of(BuildContext context) {
    FigmaFormInterface? interface = maybeOf(context);
    assert(() {
      if (interface == null) {
        throw FlutterError(
          'FigmaForm operation requested with a context that does not include a FigmaForm.\n'
              'The context used to access the state must be that of a widget that'
              'is a descendant of a FigmaForm widget.',
        );
      }
      return true;
    }());
    return interface!;
  }

  @override
  StatefulFigmaNodeState createState() => FigmaFormState();
}

class FigmaFormState extends StatefulFigmaNodeState<FigmaForm> {
  late final FigmaFormHandler handler;
  Map<String, FigmaFormInput> inputs = {};

  bool _figmaFormHandlerChanged = false;
  bool get figmaFormHandlerChanged => _figmaFormHandlerChanged;
  set figmaFormHandlerChanged(bool value) {
    if (value != _figmaFormHandlerChanged) {
      if (mounted && value) {
        setState(() {
          _figmaFormHandlerChanged = value;
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _figmaFormHandlerChanged = false
          );
        });
      } else {
        _figmaFormHandlerChanged = value;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    var formId = widget.model.userData.maybeGet('form');
    handler = FigmaFormHandlerRegistry().getHandler(formId);
    handler.onInit(this);
  }

  @override
  void dispose() {
    handler.onDispose(this);
    inputs.forEach((key, value) {
      value.node.dispose();
    });
    super.dispose();
  }

  bool shouldDisplayInput(String id) {
    return handler.shouldDisplayInput(id);
  }

  Future<(FocusNode, T)> registerInput<T>(String id, T initialValue) async {
    if (inputs.containsKey(id)) {
      logger.w('Input with id $id already exists.');
    }
    FocusNode node = FocusNode();
    T value = await handler.initialValueForInputID<T>(context, id) ?? initialValue;
    inputs[id] = FigmaFormInput<T>(node, id, value);
    if (context.mounted && mounted) {
      handler.onInputRegistered(context, inputs, inputs[id]!);
    }
    return (node, value);
  }

  void inputValueChanged<T>(String id, T value) {
    if (!inputs.containsKey(id)) {
      throw 'Input with id $id does not exist';
    }
    inputs[id]!.value = value;
    handler.onInputValueChanged(context, inputs, inputs[id]!);
  }

  void inputEditingComplete(String id) {
    if (!inputs.containsKey(id)) {
      throw 'Input with id $id does not exist';
    }
    handler.onInputEditingComplete(context, inputs, inputs[id]!);
  }

  void inputSubmitted<T>(String id, T value) {
    if (!inputs.containsKey(id)) {
      throw 'Input with id $id does not exist';
    }
    inputs[id]!.value = value;
    handler.onInputSubmitted(context, inputs, inputs[id]!);
  }

  void submit(String id, Map<String, dynamic>? buttonData) {
    handler.onSubmit(context, inputs, widget.model.userData, id, buttonData);
  }

  @override
  Widget buildFigmaNode(BuildContext context) {
    return FigmaFormInterface(
      shouldDisplayInput: shouldDisplayInput,
      registerInput: registerInput,
      inputValueChanged: inputValueChanged,
      inputEditingComplete: inputEditingComplete,
      inputSubmitted: inputSubmitted,
      submit: submit,
      getFigmaFormHandlerChanged: () => figmaFormHandlerChanged,
      child: FigmaFrame.buildFigmaFrame(context, widget.model),
    );
  }
}

typedef ShouldDisplayInputFunction = bool Function(String id);
typedef RegisterInputFunction = Future<(FocusNode, T)> Function<T>(String id, T initialValue);
typedef InputValueChangedFunction = void Function<T>(String id, T value);
typedef InputEditingCompleteFunction = void Function(String id);
typedef InputSubmittedFunction = void Function<T>(String id, T value);
typedef SubmitFunction = void Function(String id, Map<String, dynamic>? buttonData);


class FigmaFormInterface extends InheritedWidget {
  final ShouldDisplayInputFunction shouldDisplayInput;
  final RegisterInputFunction registerInput;
  final InputValueChangedFunction inputValueChanged;
  final InputEditingCompleteFunction inputEditingComplete;
  final InputSubmittedFunction inputSubmitted;
  final SubmitFunction submit;
  final bool Function() getFigmaFormHandlerChanged;

  const FigmaFormInterface({
    required this.shouldDisplayInput,
    required this.registerInput,
    required this.inputValueChanged,
    required this.inputEditingComplete,
    required this.inputSubmitted,
    required this.submit,
    required this.getFigmaFormHandlerChanged,
    required super.child,
    super.key
  });

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return getFigmaFormHandlerChanged();
  }
}
