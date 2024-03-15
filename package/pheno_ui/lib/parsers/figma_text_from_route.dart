import 'package:flutter/widgets.dart';

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
      if (arguments is Map<String, dynamic>) {
        var data = arguments['data'];
        if (data is Map<String, dynamic>) {
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