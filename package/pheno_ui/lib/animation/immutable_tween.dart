import 'package:flutter/animation.dart';

class ImmutableTween<T> extends Animatable<T> {
  final T begin;
  final T end;
  final Curve? curve;

  const ImmutableTween({
    required this.begin,
    required this.end,
    this.curve,
  });

  @override
  T transform(double t) {
    if (t == 0.0) {
      return begin;
    }
    if (t == 1.0) {
      return end;
    }

    t = curve?.transform(t) ?? t;

    // ignore: avoid_dynamic_calls
    return (begin as dynamic) + ((end as dynamic) - (begin as dynamic)) * t as T;
  }
}

class ImmutableConstantTween<T> extends Animatable<T> {
  final T value;

  const ImmutableConstantTween(this.value);

  @override
  T transform(double t) {
    return value;
  }
}

class ImmutableTweenSequence<T> extends Animatable<T> {
  final List<TweenSequenceItem<T>> _items;

  const ImmutableTweenSequence(this._items);

  @override
  T transform(double t) {
    if (t == 1.0) {
      return _items.last.tween.transform(t);
    }
    double start = 0.0;
    for (int index = 0; index < _items.length; index++) {
      if (_items[index].weight <= t - start) {
        return _items[index].tween.transform((t - start) / _items[index].weight);
      }
      start += _items[index].weight;
    }
    // Should be unreachable.
    throw StateError('TweenSequence.evaluate() could not find an interval for $t');
  }
}
