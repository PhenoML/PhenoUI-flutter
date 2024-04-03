import 'dart:math' as math;

import 'package:flutter/animation.dart';
import 'package:pheno_ui/animation/immutable_tween.dart';
import 'package:pheno_ui/animation/tween_segment.dart';

class MultiTween extends Animatable<Map<String, dynamic>> {
  final Map<String, Animatable> _map;

  MultiTween(): _map = {};
  const MultiTween.from(this._map);

  factory MultiTween.combine(List<MultiTween> others) {
    final combined = MultiTween();
    for (final tween in others) {
      combined._map.addAll(tween._map);
    }
    return combined;
  }

  Animatable? operator[](String key) {
    return _map[key];
  }

  void operator []=(String key, Animatable value) {
    _map[key] = value;
  }

  Animatable? remove(String key) {
    return _map.remove(key);
  }

  void clear() {
    _map.clear();
  }

  @override
  Map<String, dynamic> transform(double t) {
    return Map<String, dynamic>.unmodifiable(_map.map((key, value) => MapEntry(key, value.transform(t))));
  }
}

extension MultiTweenLibrary on MultiTween {
  static const MultiTween slideInFromBottom = MultiTween.from(
    {
      'offset': ImmutableTween(begin: Offset(0.0, 1.0), end: Offset.zero, curve: Curves.easeOut),
    }
  );

  static const MultiTween slideOutToTop = MultiTween.from(
    {
      'offset': ImmutableTween(begin: Offset.zero, end: Offset(0.0, -1.0), curve: Curves.easeOut),
    }
  );

  static const MultiTween slideInFromTop = MultiTween.from(
    {
      'offset': ImmutableTween(begin: Offset(0.0, -1.0), end: Offset.zero, curve: Curves.easeOut),
    }
  );

  static const MultiTween slideOutToBottom = MultiTween.from(
    {
      'offset': ImmutableTween(begin: Offset.zero, end: Offset(0.0, 1.0), curve: Curves.easeOut),
    }
  );

  static const MultiTween slideInFromLeft = MultiTween.from(
    {
      'offset': ImmutableTween(begin: Offset(-1.0, 0.0), end: Offset.zero, curve: Curves.easeOut),
    }
  );

  static const MultiTween slideOutToRight = MultiTween.from(
    {
      'offset': ImmutableTween(begin: Offset.zero, end: Offset(1.0, 0.0), curve: Curves.easeOut),
    }
  );

  static const  MultiTween slideInFromRight = MultiTween.from(
    {
      'offset': ImmutableTween(begin: Offset(1.0, 0.0), end: Offset.zero, curve: Curves.easeOut),
    }
  );

  static const MultiTween slideOutToLeft = MultiTween.from(
    {
      'offset': ImmutableTween(begin: Offset.zero, end: Offset(-1.0, 0.0), curve: Curves.easeOut),
    }
  );

  static const MultiTween bounceInFromBottom = MultiTween.from(
    {
      'offset': ImmutableTween(begin: Offset(0.0, 1.0), end: Offset.zero, curve: Curves.bounceOut),
    }
  );

  static const MultiTween elasticInFromBottom = MultiTween.from(
    {
      'offset': ImmutableTween(begin: Offset(0.0, 1.0), end: Offset.zero, curve: ElasticOutCurve(0.65)),
    }
  );

  static const MultiTween carouselInFromRight = MultiTween.from(
      {
        'offset': TweenSegment(
          start: 0.0,
          end: 0.95,
          animatable: ImmutableTween(begin: Offset(1.0, 0.0), end: Offset.zero, curve: Curves.easeOut),
        ),

        'scaleAnchor': ImmutableConstantTween(Offset(0.5, 0.5)),
        'scale': TweenSegment(
          start: 0.5,
          end: 1.0,
          animatable: ImmutableTween(begin: 0.9, end: 1.0, curve: Curves.easeOut),
        ),
      }
  );

  static const MultiTween carouselOutToLeft = MultiTween.from(
      {
        'offset': TweenSegment(
          start: 0.05,
          end: 1.0,
          animatable: ImmutableTween(begin: Offset.zero, end: Offset(-1.0, 0.0), curve: Curves.easeOut),
        ),

        'scaleAnchor': ImmutableConstantTween(Offset(0.5, 0.5)),
        'scale': TweenSegment(
          start: 0.0,
          end: 0.5,
          animatable: ImmutableTween(begin: 1.0, end: 0.9, curve: Curves.easeOut),
        ),
      }
  );

  static const MultiTween wiggleInFromRight = MultiTween.from(
    {
      'offset': TweenSegment(
        start: 0.0,
        end: 0.35,
        animatable: ImmutableTween(begin: Offset(1.0, 0.0), end: Offset.zero, curve: Curves.easeOut),
      ),

      'scaleAnchor': ImmutableConstantTween(Offset(0.5, 0.5)),
      'scale': TweenSegment(
        start: 0.5,
        end: 1.0,
        animatable: ImmutableTween(begin: 0.9, end: 1.0, curve: Curves.easeOut),
      ),

      'rotationAnchor': ImmutableConstantTween(Offset(0.5, 1.0)),
      'rotation': TweenSegment(
        start: 0.25,
        end: 1.0,
        animatable: ImmutableTween(begin: math.pi * 0.05, end: 0.0, curve: Curves.elasticOut),
      ),
    }
  );

  static const MultiTween wiggleOutToLeft = MultiTween.from(
      {
        'offset': TweenSegment(
          start: 0.2,
          end: 0.5,
          animatable: ImmutableTween(begin: Offset.zero, end: Offset(-1.0, 0.0), curve: Curves.easeOut),
        ),

        'scaleAnchor': ImmutableConstantTween(Offset(0.5, 0.5)),
        'scale': TweenSegment(
          start: 0.0,
          end: 0.3,
          animatable: ImmutableTween(begin: 1.0, end: 0.9, curve: Curves.easeOut),
        ),

        'rotationAnchor': ImmutableConstantTween(Offset(0.5, 1.0)),
        'rotation': ImmutableTweenSequence(
          [
            TweenSequenceItem(tween: ImmutableConstantTween(0.0), weight: 0.05),
            TweenSequenceItem(
              tween: ImmutableTween(begin: 0.0, end: math.pi * 0.05, curve: Curves.easeOut),
              weight: 0.25,
            ),
            TweenSequenceItem(
              tween: ImmutableTween(begin: math.pi * 0.05, end: 0.0, curve: Curves.elasticOut),
              weight: 0.70,
            ),
          ],
        ),
      }
  );
}