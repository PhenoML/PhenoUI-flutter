import 'package:flutter/widgets.dart';
import 'package:mirai/mirai.dart';

import '../models/figma_simple_child_model.dart';

class FigmaSafeAreaParser extends MiraiParser<FigmaSimpleChildModel> {
  const FigmaSafeAreaParser();

  @override
  FigmaSimpleChildModel getModel(Map<String, dynamic> json) =>
      FigmaSimpleChildModel.fromJson(json);

  @override
  String get type => 'figma-safe-area';

  @override
  Widget parse(BuildContext context, FigmaSimpleChildModel model) {
    return SafeArea(
      child: Mirai.fromJson(model.child, context) ?? const SizedBox(),
    );
  }
}