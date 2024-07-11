import 'package:flutter/widgets.dart';

import 'figma_frame.dart';
import 'figma_slider.dart';

class FigmaSliderTicks extends FigmaFrame {
  final List<Widget> tickWidgets;

  FigmaSliderTicks({
    required super.model,
    super.key,
  }) : tickWidgets = <Widget>[...model.children] {
    model.children.clear();
  }

  static FigmaSliderTicks fromJson(Map<String, dynamic> json) {
    return FigmaFrame.fromJson(json, FigmaSliderTicks.new);
  }

  @override
  void onMount(BuildContext context) {
    super.onMount(context);
    FigmaSliderInterface? slider = FigmaSlider.maybeOf(context, listen: false);
    if (slider != null) {
      int tickCount = (slider.maxValue - slider.minValue) ~/ slider.increment;
      String behaviour = model.userData.get('behaviour', context: context, listen: false);
      model.children.clear();
      switch(behaviour) {
        case 'repeatLast':
          int n = tickWidgets.length;
          for (int i = 0; i <= tickCount; i++) {
            Widget tick = tickWidgets[i >= n ? n - 1 : i];
            model.children.add(tick);
          }
          break;

        case 'cycle':
          for (int i = 0; i <= tickCount; i++) {
            Widget tick = tickWidgets[i % tickWidgets.length];
            model.children.add(tick);
          }
          break;

        case 'mirror':
          int n = tickWidgets.length;
          int ii = 0;
          int pp = 1;
          for (int i = 0; i <= tickCount; i++) {
            Widget tick = tickWidgets[ii];
            model.children.add(tick);
            if (ii >= n - 1) {
              pp = -1;
            } else if (ii <= 0) {
              pp = 1;
            }
            ii += pp;
          }
          break;

        case 'first':
          for (int i = 0; i <= tickCount; i++) {
            Widget tick = tickWidgets[0];
            model.children.add(tick);
          }
          break;

        case 'last':
          int ii = tickWidgets.length - 1;
          for (int i = 0; i <= tickCount; i++) {
            Widget tick = tickWidgets[ii];
            model.children.add(tick);
          }
          break;

        case 'none':
        default:
          break;
      }
    }
  }

  @override
  Widget buildFigmaNode(BuildContext context) {
    return super.buildFigmaNode(context);
  }
}
