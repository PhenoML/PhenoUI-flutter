import 'package:flutter/widgets.dart';

import '../models/figma_component_model.dart';
import '../tools/figma_form_types.dart';
import '../tools/figma_user_data.dart';
import 'figma_component.dart';
import 'figma_form.dart';

class FigmaCheckbox extends FigmaComponent with FigmaFormWidget {
  const FigmaCheckbox({
    required super.stateNew,
    required super.model,
    required super.key
  });

  static FigmaComponent fromJson(Map<String, dynamic> json) {
    return figmaComponentFromJson(json, FigmaCheckbox.new, FigmaComponentModel.fromJson, FigmaCheckboxState.new);
  }
}

class FigmaCheckboxState extends FigmaComponentState {
  FigmaFormInterface? form;
  FocusNode? focusNode;
  String _state = 'unchecked';
  bool _hasInitialValue = false;
  late final FigmaUserData widgetUserData = widget.model.userData;
  late final String _id = widgetUserData.get('id', context: context, listen: false);

  bool get checked => _state == 'checked';
  set checked(bool value) {
    String newState = value ? 'checked' : 'unchecked';
    if (_state != newState) {
      _state = newState;
      setVariant(widgetUserData.get('state'), widgetUserData.get(_state));
      if (form != null) {
        form!.inputValueChanged(_id, checked);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    form = FigmaForm.maybeOf(context, listen: false);
  }

  @override
  void initVariantData() {
    super.initVariantData();
    if (form != null) {
      form!.registerInput(_id, checked).then((value) {
        focusNode = value.$1;
        checked = value.$2;
        _hasInitialValue = true;
      });
    }
  }

  @override
  void initVariant() {
    setVariant(widgetUserData.get('state'), widgetUserData.get(_state));
  }

  @override
  Widget buildFigmaNode(BuildContext context) {
    if (!_hasInitialValue) {
      return const SizedBox();
    }

    return GestureDetector(
      onTap: () {
        checked = !checked;
      },
      child: super.buildFigmaNode(context),
    );
  }
}
