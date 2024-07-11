import 'package:flutter/widgets.dart';
import 'package:format/format.dart';

import '../models/figma_text_model.dart';
import 'figma_slider.dart';
import 'figma_text.dart';

class FigmaSliderLabel extends FigmaText {
  final String labelFormat;

  FigmaSliderLabel({
    required super.model, super.key
  }) : labelFormat = model.userData.get('labelFormat');

  static FigmaSliderLabel fromJson(Map<String, dynamic> json) {
    final FigmaTextModel model = FigmaTextModel.fromJson(json);
    return FigmaSliderLabel(model: model);
  }

  @override
  String? getCharacters(BuildContext context) {
    FigmaSliderInterface? slider = FigmaSlider.maybeOf(context);
    if (slider != null) {
      double percent = (slider.value - slider.minValue) / (slider.maxValue - slider.minValue) * 100;
      String? userLabel = slider.userLabels?[slider.value.toString()];
      if (userLabel == null && slider.value == slider.value.truncateToDouble()) {
        userLabel = slider.userLabels?[slider.value.round().toString()];
      }
      return format(labelFormat, {
        'percent': percent,
        'value': slider.value,
        'minValue': slider.minValue,
        'maxValue': slider.maxValue,
        'label': userLabel ?? '',
      });
    }
    return super.getCharacters(context);
  }
}