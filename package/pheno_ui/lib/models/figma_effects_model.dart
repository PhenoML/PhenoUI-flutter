import 'dart:ui';

import 'package:flutter/widgets.dart';

import '../interface/log.dart';
import '../widgets/inner_shadow.dart';
import '../widgets/outer_shadow.dart';

class FigmaEffectsModel {
  final List<_FigmaEffect> _effects;
  FigmaEffectsModel._(this._effects);

  factory FigmaEffectsModel.fromJson(List<dynamic> json) {
    List<_FigmaEffect> effects = [];
    for (Map<String, dynamic> effect in json) {
      var type = effect['type'];
      switch (type) {
        case 'DROP_SHADOW':
          effects.add(_FigmaDropShadow.fromJson(effect));
          break;

        case 'INNER_SHADOW':
          effects.add(_FigmaInnerShadow.fromJson(effect));
          break;

        case 'LAYER_BLUR':
          effects.add(_FigmaLayerBlur.fromJson(effect));
          break;

        case 'BACKGROUND_BLUR':
          effects.add(_FigmaBackgroundBlur.fromJson(effect));
          break;

        default:
          throw UnimplementedError('Unknown effect type: $type');
      }
    }

    effects.sort((a, b) {
      int aVal = switch (a.runtimeType) {
        _FigmaDropShadow => 1,
        _FigmaInnerShadow => 2,
        _FigmaLayerBlur => 3,
        _FigmaBackgroundBlur => 4,
        _ => 0,
      };

      int bVal = switch (b.runtimeType) {
        _FigmaDropShadow => 1,
        _FigmaInnerShadow => 2,
        _FigmaLayerBlur => 3,
        _FigmaBackgroundBlur => 4,
        _ => 0,
      };

      return bVal - aVal;
    });

    return FigmaEffectsModel._(effects);
  }

  Widget apply(Widget child) {
    return _effects.fold(child, (child, effect) => effect.apply(child));
  }
}

abstract class _FigmaEffect {
  Widget apply(Widget child);
}

class _FigmaDropShadow extends _FigmaEffect {
  final Offset offset;
  final double radius;
  final Color color;
  final double spread;
  final bool visible;

  _FigmaDropShadow({
    required this.offset,
    required this.radius,
    required this.color,
    required this.spread,
    required this.visible,
  });

  factory _FigmaDropShadow.fromJson(Map<String, dynamic> json) {
    var color = Color.fromRGBO(
      (json['color']['r'] * 255.0).round(),
      (json['color']['g'] * 255.0).round(),
      (json['color']['b'] * 255.0).round(),
      (json['color']['a'] ?? 1.0).toDouble(),
    );

    return _FigmaDropShadow(
      offset: Offset(json['offset']['x'].toDouble(), json['offset']['y'].toDouble()),
      radius: json['radius'].toDouble(),
      color: color,
      spread: json['spread'].toDouble(),
      visible: json['visible'] ?? true,
    );
  }

  @override
  Widget apply(Widget child) {
    if (!visible) return child;

    return OuterShadow(
      shadows: [
        BoxShadow(
          offset: offset,
          blurRadius: radius,
          color: color,
          spreadRadius: spread,
          blurStyle: BlurStyle.normal,
        ),
      ],
      child: child,
    );
  }
}

class _FigmaInnerShadow extends _FigmaEffect {
  final Offset offset;
  final double radius;
  final Color color;
  final double spread;
  final bool visible;

  _FigmaInnerShadow({
    required this.offset,
    required this.radius,
    required this.color,
    required this.spread,
    required this.visible,
  });

  factory _FigmaInnerShadow.fromJson(Map<String, dynamic> json) {
    var color = Color.fromRGBO(
      (json['color']['r'] * 255.0).round(),
      (json['color']['g'] * 255.0).round(),
      (json['color']['b'] * 255.0).round(),
      (json['color']['a'] ?? 1.0).toDouble(),
    );

    return _FigmaInnerShadow(
      offset: Offset(json['offset']['x'].toDouble(), json['offset']['y'].toDouble()),
      radius: json['radius'].toDouble(),
      color: color,
      spread: json['spread'].toDouble(),
      visible: json['visible'] ?? true,
    );
  }

  @override
  Widget apply(Widget child) {
    if (!visible) return child;

    return InnerShadow(
      shadows: [
        BoxShadow(
          offset: offset,
          blurRadius: radius,
          color: color,
          spreadRadius: spread,
        ),
      ],
      child: child,
    );
  }
}

class _FigmaLayerBlur extends _FigmaEffect {
  final double radius;
  final bool visible;

  _FigmaLayerBlur({
    required this.radius,
    required this.visible,
  });

  factory _FigmaLayerBlur.fromJson(Map<String, dynamic> json) {
    return _FigmaLayerBlur(
      radius: json['radius'].toDouble(),
      visible: json['visible'] ?? true,
    );
  }

  @override
  Widget apply(Widget child) {
    if (!visible) return child;

    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: radius * 0.5, sigmaY: radius * 0.5, tileMode: TileMode.decal),
      child: child,
    );
  }
}

class _FigmaBackgroundBlur extends _FigmaEffect {
  final double radius;
  final bool visible;

  _FigmaBackgroundBlur({
    required this.radius,
    required this.visible,
  });

  factory _FigmaBackgroundBlur.fromJson(Map<String, dynamic> json) {
    return _FigmaBackgroundBlur(
      radius: json['radius'].toDouble(),
      visible: json['visible'] ?? true,
    );
  }

  @override
  Widget apply(Widget child) {
    if (!visible) return child;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: radius * 0.5, sigmaY: radius * 0.5),
        child: child,
      ),
    );
  }
}



