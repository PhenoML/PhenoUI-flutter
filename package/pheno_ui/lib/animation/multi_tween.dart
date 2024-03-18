import 'dart:math' as math;

import 'package:flutter/animation.dart';
import 'package:pheno_ui/animation/tween_segment.dart';

class MultiTween extends Animatable<Map<String, dynamic>> {
  final Map<String, Animatable> _map = <String, Animatable>{};

  MultiTween();

  factory MultiTween.from(Map<String, Animatable> values) {
    return MultiTween().._map.addAll(values);
  }

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
  static final MultiTween wiggleInLeft = MultiTween.from(
    {
      'offset': TweenSegment(
        start: 0.0,
        end: 0.35,
        animatable:Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOut)),
      ),

      'rotationAnchor': ConstantTween(const Offset(0.5, 1.0)),
      'rotation': TweenSegment(
        start: 0.25,
        end: 1.0,
        animatable: Tween(begin: math.pi * 0.05, end: 0.0).chain(CurveTween(curve: Curves.elasticOut)),
      ),

      'scaleAnchor': ConstantTween(const Offset(0.5, 0.5)),
      'scale': TweenSegment(
        start: 0.5,
        end: 1.0,
        animatable: Tween(begin: 0.9, end: 1.0).chain(CurveTween(curve: Curves.easeOut)),
      ),
    }
  );

  static final MultiTween wiggleOutLeft = MultiTween.from(
      {
        'offset': TweenSegment(
          start: 0.2,
          end: 0.5,
          animatable:Tween(begin: Offset.zero, end: const Offset(-1.0, 0.0)).chain(CurveTween(curve: Curves.easeOut)),
        ),

        'rotation': TweenSequence(
          [
            TweenSequenceItem(tween: ConstantTween(0.0), weight: 0.05),
            TweenSequenceItem(
              tween: Tween(begin: 0.0, end: math.pi * 0.05).chain(CurveTween(curve: Curves.easeOut)),
              weight: 0.25,
            ),
            TweenSequenceItem(
              tween: Tween(begin: math.pi * 0.05, end: 0.0).chain(CurveTween(curve: Curves.elasticOut)),
              weight: 0.70,
            ),
          ],
        ),

        'rotationAnchor': ConstantTween(const Offset(0.5, 1.0)),
        // 'rotation': TweenSegment(
        //   start: 0.25,
        //   end: 1.0,
        //   animatable: Tween(begin: 0.0, end: math.pi * 0.05).chain(CurveTween(curve: Curves.elasticOut)),
        // ),

        'scaleAnchor': ConstantTween(const Offset(0.5, 0.5)),
        'scale': TweenSegment(
          start: 0.0,
          end: 0.3,
          animatable: Tween(begin: 1.0, end: 0.9).chain(CurveTween(curve: Curves.easeOut)),
        ),
      }
  );
}