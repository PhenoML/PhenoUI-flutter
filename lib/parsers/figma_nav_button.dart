import 'package:flutter/widgets.dart';
import 'package:mirai/mirai.dart';
import 'package:phenoui_flutter/models/figma_frame_model.dart';

import '../models/figma_nav_button_model.dart';

class FigmaNavButtonParser extends MiraiParser<FigmaNavButtonModel> {
  const FigmaNavButtonParser();

  @override
  FigmaNavButtonModel getModel(Map<String, dynamic> json) => FigmaNavButtonModel.fromJson(json);

  @override
  String get type => 'figma-nav-button';

  @override
  Widget parse(BuildContext context, FigmaNavButtonModel model) {
    var onTap = switch (model.action) {
      FigmaNavButtonAction.pop => () => Navigator.of(context).pop(),
      FigmaNavButtonAction.push => () => Navigator.of(context).pushNamed(model.target!),
      FigmaNavButtonAction.replace => () => Navigator.of(context).pushReplacementNamed(model.target!),
    };

    var frameModel = FigmaFrameModel.fromJson(model.child, (child) => GestureDetector(onTap: onTap, child: child));
    var parser = MiraiRegistry.instance.getParser(model.child['type']);
    return parser?.parse(context, frameModel) ?? const SizedBox();
  }
}