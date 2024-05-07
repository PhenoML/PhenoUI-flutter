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
  final Widget? childrenContainer;

  const FigmaForm({
    required super.model,
    this.childrenContainer,
    super.key
  });

  static FigmaForm fromJson(Map<String, dynamic> json) {
    return FigmaFrame.fromJson(json, FigmaForm.new);
  }

  static FigmaFormState? maybeOf(BuildContext context) {
    // Handles the case where the input context is a FigmaForm element.
    FigmaFormState? state;

    if (context is StatefulElement && context.state is FigmaFormState) {
      state = context.state as FigmaFormState;
    }
    state = state ?? context.findAncestorStateOfType<FigmaFormState>();

    return state;
  }

  static FigmaFormState of(BuildContext context) {
    FigmaFormState? state = maybeOf(context);
    assert(() {
      if (state == null) {
        throw FlutterError(
          'FigmaForm operation requested with a context that does not include a FigmaForm.\n'
              'The context used to access the state must be that of a widget that'
              'is a descendant of a FigmaForm widget.',
        );
      }
      return true;
    }());
    return state!;
  }

  @override
  StatefulFigmaNodeState createState() => FigmaFormState();
}

class FigmaFormState extends StatefulFigmaNodeState<FigmaForm> {
  late final FigmaFormHandler handler;
  Map<String, FigmaFormInput> inputs = {};

  @override
  void initState() {
    super.initState();
    var formId = widget.model.userData.maybeGet('form');
    handler = FigmaFormHandlerRegistry().getHandler(formId);
  }

  @override
  void dispose() {
    inputs.forEach((key, value) {
      value.node.dispose();
    });
    super.dispose();
  }

  bool shouldDisplayInput(String id) {
    return handler.shouldDisplayInput(id) ?? true;
  }

  Future<(FocusNode, T)> registerInput<T>(String id, T initialValue) async {
    if (inputs.containsKey(id)) {
      logger.w('Input with id $id already exists.');
    }
    FocusNode node = FocusNode();
    T value = await handler.initialValueForInputID<T>(context, inputs, id) ?? initialValue;
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
    return FigmaFrame.buildFigmaFrame(context, widget.model);
  }
}
