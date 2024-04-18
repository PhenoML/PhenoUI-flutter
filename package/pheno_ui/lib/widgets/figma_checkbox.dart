import 'package:flutter/widgets.dart';

import '../models/figma_component_model.dart';
import 'figma_component.dart';
import 'figma_form.dart';

class FigmaCheckbox extends FigmaComponent {
  const FigmaCheckbox({required super.stateNew, required super.model, required super.key});

  static FigmaComponent fromJson(Map<String, dynamic> json) {
    return figmaComponentFromJson(json, FigmaComponent.new, FigmaComponentModel.fromJson, FigmaCheckboxState.new);
  }
}

class FigmaCheckboxState extends FigmaComponentState {
  FigmaFormState? form;
  FocusNode? focusNode;
  String _state = 'unchecked';
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
    form = FigmaForm.maybeOf(context);
    if (form != null) {
      focusNode = form!.registerInput(_id, checked);
    }
  }

  @override
  void initVariant() {
    setVariant(userData.get('state'), userData.get(_state));
  }

  @override
  Widget buildFigmaNode(BuildContext context) {
    if (form != null && !form!.shouldDisplayInput(_id)) {
      return const SizedBox();
    }

    return GestureDetector(
      onTap: () {
        print('onTap ${widget.model.info.name}');
        checked = !checked;
      },
      child: super.buildFigmaNode(context),
    );
  }
}
