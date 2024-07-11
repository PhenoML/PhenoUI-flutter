import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:pheno_ui/tools/figma_form_types.dart';
import 'package:pheno_ui/tools/figma_user_data.dart';

import '../models/figma_frame_model.dart';
import '../tools/figma_form_handler.dart';
import 'figma_checkbox.dart';
import 'figma_form.dart';
import 'figma_frame.dart';
import 'stateful_figma_node.dart';

class FigmaRadioButtonGroup extends StatefulFigmaNode<FigmaFrameModel> {
  const FigmaRadioButtonGroup({
    required super.model,
    super.key,
  });

  static FigmaRadioButtonGroup fromJson(Map<String, dynamic> json) {
    return FigmaFrame.fromJson(json, FigmaRadioButtonGroup.new);
  }

  @override
  FigmaRadioButtonGroupState createState() => FigmaRadioButtonGroupState();
}

class _FigmaRadioButtonGroupHandler extends FigmaFormHandler {
  final FigmaRadioButtonGroupState state;
  const _FigmaRadioButtonGroupHandler(this.state);

  @override
  FutureOr<T?> initialValueForInputID<T>(BuildContext context, String id) {
    if (T == bool) {
      if (id == state.value) {
        return true as T;
      }
      return false as T;
    }
    return null;
  }

  @override
  void onInputValueChanged<T>(
    BuildContext context,
    Map<String, FigmaFormInput> inputs,
    FigmaFormInput<T> input
  ) {
    if (input.id == state.value) {
      state.value = input.value as bool ? input.id : '';
    } else if (input.value as bool) {
      state.value = input.id;
      for (var i in inputs.values) {
        if (i != input && i.node.context is StatefulElement && (i.node.context as StatefulElement).state is FigmaCheckboxState) {
          FigmaCheckboxState checkboxState = (i.node.context! as StatefulElement).state as FigmaCheckboxState;
          checkboxState.checked = false;
        }
      }
    }
  }
  
  @override
  void onSubmit(BuildContext context, Map<String, FigmaFormInput<dynamic>> inputs, FigmaUserData userData, String buttonId, Map<String, dynamic>? buttonData) {
    // do nothing
  }
}

class FigmaRadioButtonGroupState extends FigmaFormState<FigmaRadioButtonGroup> {
  FigmaFormInterface? form;
  FocusNode? focusNode;
  late final String _id = widget.model.userData.get('id', context: context, listen: false);
  late String _value = widget.model.userData.get('initialValue');
  String get value => _value;
  set value(String value) {
    _value = value;
    if (form != null) {
      form!.inputValueChanged(_id, value);
    }
  }

  @override
  void initFormState() {
    handler = _FigmaRadioButtonGroupHandler(this);
    form = FigmaForm.maybeOf(context, listen: false);
    if (form != null) {
      form!.registerInput(_id, value).then((value) {
        focusNode = value.$1;
        _value = value.$2;
      });
    }
  }
}
