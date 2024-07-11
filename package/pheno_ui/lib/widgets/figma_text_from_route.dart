import 'package:flutter/widgets.dart';

import '../interface/route_arguments.dart';
import '../models/figma_text_model.dart';
import 'figma_text.dart';

class FigmaTextFromRoute extends FigmaText {
  const FigmaTextFromRoute({required super.model, super.key});

  static FigmaTextFromRoute fromJson(Map<String, dynamic> json) {
    final FigmaTextModel model = FigmaTextModel.fromJson(json);
    return FigmaTextFromRoute(model: model);
  }

  @override
  String? getCharacters(BuildContext context) {
    String? key = model.userData.maybeGet('key');
    if (key is String) {
      var arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments is RouteArguments) {
        var data = arguments.data;
        if (data != null) {
          var text = data[key];
          if (text is String) {
            return text;
          }
        }
      }
    }
    return super.getCharacters(context);
  }
}