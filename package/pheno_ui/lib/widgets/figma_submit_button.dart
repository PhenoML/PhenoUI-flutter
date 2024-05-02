import 'package:flutter/widgets.dart';

import '../tools/figma_form_types.dart';
import 'figma_form.dart';
import 'figma_frame.dart';

class FigmaSubmitButton extends FigmaFrame with FigmaFormWidget {
  const FigmaSubmitButton({
    required super.model,
    super.key
  });

  static FigmaSubmitButton fromJson(Map<String, dynamic> json) {
    return FigmaFrame.fromJson(json, FigmaSubmitButton.new);
  }

  @override
  Widget buildFigmaNode(BuildContext context) {
    var form = FigmaForm.maybeOf(context);
    String id = model.userData.maybeGet('id') ?? model.info.name!;

    onTap() {
      form?.submit(id, model.userData.maybeGet('context'));
    }

    return GestureDetector(
      onTap: onTap,
      child: super.buildFigmaNode(context),
    );
  }
}