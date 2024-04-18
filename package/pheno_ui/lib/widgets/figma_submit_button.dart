import 'package:flutter/widgets.dart';

import 'figma_form.dart';
import 'figma_frame.dart';

class FigmaSubmitButton extends FigmaFrame {
  const FigmaSubmitButton({
    required super.model,
    super.childrenContainer,
    super.key
  });

  static FigmaSubmitButton fromJson(Map<String, dynamic> json) {
    return FigmaFrame.fromJson(json, FigmaSubmitButton.new);
  }

  @override
  Widget buildFigmaNode(BuildContext context) {
    var form = FigmaForm.maybeOf(context);
    String id = model.userData.maybeGet('id') ?? model.info.name!;

    if (form != null && !form.shouldDisplayInput(id)) {
      return const SizedBox();
    }

    onTap() {
      form?.submit(id, model.userData.maybeGet('context'));
    }

    return GestureDetector(
      onTap: onTap,
      child: super.buildFigmaNode(context),
    );
  }
}