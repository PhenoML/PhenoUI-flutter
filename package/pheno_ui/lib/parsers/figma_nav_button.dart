import 'package:flutter/widgets.dart';
import 'package:mirai/mirai.dart';
import '../models/figma_frame_model.dart';
import '../models/figma_nav_button_model.dart';

class FigmaNavButtonParser extends MiraiParser<FigmaNavButtonModel> {
  const FigmaNavButtonParser();

  @override
  FigmaNavButtonModel getModel(Map<String, dynamic> json) => FigmaNavButtonModel.fromJson(json);

  @override
  String get type => 'figma-nav-button';

  @override
  Widget parse(BuildContext context, FigmaNavButtonModel model) {
    Map<String, dynamic>? data = model.userData.maybeGet('data');
    var onTap = switch (model.action) {
      FigmaNavButtonAction.pop => () => Navigator.of(context).pop(data ?? model.target),
      FigmaNavButtonAction.push => () => Navigator.of(context).pushNamed(model.target!, arguments: { 'type': 'screen', 'data': data }),
      FigmaNavButtonAction.popup => () => Navigator.of(context).pushNamed(model.target!, arguments: { 'type': 'popup', 'data': data }),
      FigmaNavButtonAction.replace => () => Navigator.of(context).pushReplacementNamed(model.target!, arguments: { 'type': 'screen', 'data': data }),
    };

    var frameModel = FigmaFrameModel.fromJson(model.child, (context, _, builder) => GestureDetector(onTap: onTap, child: builder(context)));
    var parser = MiraiRegistry.instance.getParser(model.child['type']);
    return parser?.parse(context, frameModel) ?? const SizedBox();
  }
}