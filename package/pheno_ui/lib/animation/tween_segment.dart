import 'package:flutter/animation.dart';

class TweenSegment<T> extends Animatable<T> {
  final double start;
  final double end;
  final Animatable<T> animatable;
  const TweenSegment({
    required this.start,
    required this.end,
    required this.animatable,
  }) :  assert(start <= end),
        assert(start >= 0 && start <= 1),
        assert(end >= 0 && end <= 1);

  factory TweenSegment.duration({
    required double start,
    required double duration,
    required Animatable<T> animatable,
  }) {
    return TweenSegment(
      start: start,
      end: start + duration,
      animatable: animatable,
    );
  }

  @override
  T transform(double t) {
    return animatable.transform(((t - start) / (end - start)).clamp(0.0, 1.0));
  }
}