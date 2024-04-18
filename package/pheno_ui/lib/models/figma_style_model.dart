import 'package:flutter/material.dart';
import '../tools/figma_enum.dart';

enum FigmaStyleBlendMode with FigmaEnum {
  passThrough("PASS_THROUGH"),
  normal("NORMAL"),
  darken("DARKEN"),
  multiply("MULTIPLY"),
  linearBurn("LINEAR_BURN"), // "Plus darker" in Figma // unavailable in Flutter
  colorBurn("COLOR_BURN"),
  lighten("LIGHTEN"),
  screen("SCREEN"),
  linearDodge("LINEAR_DODGE"), // "Plus lighter" in Figma // unavailable in Flutter
  colorDodge("COLOR_DODGE"),
  overlay("OVERLAY"),
  softLight("SOFT_LIGHT"),
  hardLight("HARD_LIGHT"),
  difference("DIFFERENCE"),
  exclusion("EXCLUSION"),
  hue("HUE"),
  saturation("SATURATION"),
  color("COLOR"),
  luminosity("LUMINOSITY"),
  ;
  @override
  get figmaName => _figmaName;
  final String? _figmaName;
  const FigmaStyleBlendMode([this._figmaName]);
}

class FigmaStyleBorder extends Border {
  const FigmaStyleBorder({
    BorderSide top = BorderSide.none,
    BorderSide right = BorderSide.none,
    BorderSide bottom = BorderSide.none,
    BorderSide left = BorderSide.none,
  }) : super(
    top: top,
    right: right,
    bottom: bottom,
    left: left,
  );

  @override
  EdgeInsetsGeometry get dimensions {
    return const EdgeInsets.all(0.0);
  }

  factory FigmaStyleBorder.all({
    Color color = const Color(0xFF000000),
    double width = 1.0,
  }) {
    return FigmaStyleBorder(
      top: BorderSide(color: color, width: width),
      right: BorderSide(color: color, width: width),
      bottom: BorderSide(color: color, width: width),
      left: BorderSide(color: color, width: width),
    );
  }
}

class FigmaStyleModel {
  final Color? color;
  final double opacity;
  final BorderRadius? borderRadius;
  final Border? border;
  final FigmaStyleBlendMode blendMode;

  FigmaStyleModel._fromJson(Map<String, dynamic> json) :
    color = json['color'] == null || json['color']['r'] == null ? null : Color.fromRGBO(
      (json['color']['r'] * 255.0).round(),
      (json['color']['g'] * 255.0).round(),
      (json['color']['b'] * 255.0).round(),
      (json['color']['o'] ?? 1.0).toDouble(),
    ),
    opacity = json['opacity'].toDouble(),
    borderRadius = json['border']['radius']['tl'] == null ? null : BorderRadius.only(
      topLeft: Radius.circular(json['border']['radius']['tl'].toDouble()),
      topRight: Radius.circular(json['border']['radius']['tr'].toDouble()),
      bottomLeft: Radius.circular(json['border']['radius']['bl'].toDouble()),
      bottomRight: Radius.circular(json['border']['radius']['br'].toDouble())
    ),
    border = json['border']['color'] == null || json['border']['color']['r'] == null ? null : FigmaStyleBorder.all(
      color: Color.fromRGBO(
        (json['border']['color']['r'] * 255.0).round(),
        (json['border']['color']['g'] * 255.0).round(),
        (json['border']['color']['b'] * 255.0).round(),
        (json['color']['o'] ?? 1.0).toDouble(),
      ),
      width: json['border']['width'].toDouble()
    ),
    blendMode = FigmaStyleBlendMode.values.byNameDefault(json['blendMode'], FigmaStyleBlendMode.passThrough);

  factory FigmaStyleModel.fromJson(Map<String, dynamic> json) =>
    FigmaStyleModel._fromJson(json);
}