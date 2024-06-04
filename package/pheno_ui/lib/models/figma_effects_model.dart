import 'dart:ui';

import 'package:flutter/widgets.dart';

import '../widgets/inner_shadow.dart';
import '../widgets/outer_shadow.dart';
import '../widgets/background_blur.dart';

class FigmaEffectsModel {
  final List<_FigmaEffect> _effects;

  FigmaEffectsModel([this._effects = const []]);

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

    getSortValue(effect) {
      switch (effect.runtimeType) {
        case _FigmaDropShadow:
          return 1;
        case _FigmaInnerShadow:
          return 3;
        case _FigmaLayerBlur:
          return 4;
        case _FigmaBackgroundBlur:
          return 2;
        default:
          return 0;
      }
    }

    effects.sort((a, b) {
      int aVal = getSortValue(a);
      int bVal = getSortValue(b);

      return aVal - bVal;
    });

    return FigmaEffectsModel(effects);
  }

  Widget apply(Widget child) {
    List<Widget> children = [];
    _FigmaLayerBlur? layerBlur;
    bool addedChild = false;

    for (var effect in _effects) {
      if (effect.visible) {
        if (effect is _FigmaLayerBlur) {
          layerBlur = effect;
        } else if (!addedChild && effect is _FigmaInnerShadow) {
          children.add(child);
          children.add(effect.apply(child));
          addedChild = true;
        } else {
          children.add(effect.apply(child));
        }
      }
    }

    if (children.isNotEmpty && !addedChild) {
      children.add(child);
    }

    Widget result = children.isEmpty ? child : Stack(children: children);
    if (layerBlur != null) {
      result = layerBlur.apply(result);
    }
    return result;
  }
}

abstract class _FigmaEffect {
  bool get visible;
  Widget apply(Widget child);
}

class _FigmaDropShadow extends _FigmaEffect {
  final Offset offset;
  final double radius;
  final Color color;
  final double spread;
  final bool showBehindNode;
  @override
  final bool visible;

  _FigmaDropShadow({
    required this.offset,
    required this.radius,
    required this.color,
    required this.spread,
    required this.showBehindNode,
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
      showBehindNode: json['showShadowBehindNode'],
      visible: json['visible'] ?? true,
    );
  }

  @override
  Widget apply(Widget child) {
    if (!visible) return const SizedBox();

    return OuterShadow(
      shadows: [
        OuterShadowEntry(
          showBehindNode: showBehindNode,
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
  @override
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
    if (!visible) return const SizedBox();

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
  @override
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
      // Future Dario: 0.4 ... wtf?!?!?!
      // different blur types, I guess?
      imageFilter: ImageFilter.blur(sigmaX: radius * 0.4, sigmaY: radius * 0.4, tileMode: TileMode.decal),
      child: child,
    );
  }
}

class _FigmaBackgroundBlur extends _FigmaEffect {
  final double radius;
  @override
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
    if (!visible) return const SizedBox();

    return BackgroundBlur(
      radius: radius,
      child: child,
    );
  }
}



