import 'package:flutter/widgets.dart';

class StepTweenDouble extends Animatable<double> {
  final double begin;
  final double end;

  StepTweenDouble({
    required this.begin,
    required this.end,
  });

  @override
  double transform(double t) {
    return (begin + (end - begin) * t).floorToDouble();
  }
}