import 'package:flutter/widgets.dart';

import '../widgets/figma_form.dart';
import '../widgets/figma_node.dart';

class FigmaFormInput<T> {
  final FocusNode node;
  final String id;
  T value;
  Type get type => value.runtimeType;
  FigmaFormInput(this.node, this.id, this.value);
}

mixin FigmaFormWidget on FigmaNode {
  bool isVisible(BuildContext context) {
    var form = FigmaForm.maybeOf(context);
    String id = model.userData.maybeGet('id') ?? model.info.name!;

    if (form != null) {
      return form.shouldDisplayInput(id);
    }

    return true;
  }
}
