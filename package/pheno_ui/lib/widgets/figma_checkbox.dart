import 'package:flutter/widgets.dart';

import '../models/figma_component_model.dart';
import '../tools/figma_form_types.dart';
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
  late final String _id = userData.get('id', context: context, listen: false);

  bool get checked => _state == 'checked';
  set checked(bool value) {
    _state = value ? 'checked' : 'unchecked';
    setVariant(userData.get('state'), userData.get(_state));
    if (form != null) {
      form!.inputValueChanged(_id, checked);
    }
  }

  @override
  void initState() {
    super.initState();
    form = FigmaForm.maybeOf(context, listen: false);
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
    setVariant(userData.get('state'), userData.get(_state));
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
