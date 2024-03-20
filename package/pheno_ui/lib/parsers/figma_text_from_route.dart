import 'package:flutter/widgets.dart';
import 'package:pheno_ui/interface/route_arguments.dart';

import '../models/figma_text_model.dart';
import 'figma_text.dart';

class FigmaTextFromRouteParser extends FigmaTextParser {
  const FigmaTextFromRouteParser();

  @override
  String get type => 'figma-text-from-route';

  @override
  List<FigmaTextSegmentModel> getTextSegments(BuildContext context, FigmaTextModel model) {
    String? key = model.userData.maybeGet('key');
    if (key is String) {
      var arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments is RouteArguments) {
        var data = arguments.data;
        if (data != null) {
          var text = data[key];
          if (text is String) {
            var segment = model.segments.first;
            return [FigmaTextSegmentModel.copy(segment, characters: text)];
          }
        }
        }
    }
    return super.getTextSegments(context, model);
  }
}