import 'package:flutter/material.dart';

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

  FigmaStyleModel._fromJson(Map<String, dynamic> json) :
      color = json['color'] == null ? null : Color.fromRGBO(
          (json['color']['r'] * 255.0).round(),
          (json['color']['g'] * 255.0).round(),
          (json['color']['b'] * 255.0).round(),
          1.0
      ),
      opacity = json['opacity'].toDouble(),
      borderRadius = json['border']['radius']['tl'] == null ? null : BorderRadius.only(
          topLeft: Radius.circular(json['border']['radius']['tl'].toDouble()),
          topRight: Radius.circular(json['border']['radius']['tr'].toDouble()),
          bottomLeft: Radius.circular(json['border']['radius']['bl'].toDouble()),
          bottomRight: Radius.circular(json['border']['radius']['br'].toDouble())
      ),
      border = json['border']['color'] == null ? null : FigmaStyleBorder.all(
          color: Color.fromRGBO(
              (json['border']['color']['r'] * 255.0).round(),
              (json['border']['color']['g'] * 255.0).round(),
              (json['border']['color']['b'] * 255.0).round(),
              1.0
          ),
          width: json['border']['width'].toDouble()
      );

  factory FigmaStyleModel.fromJson(Map<String, dynamic> json) =>
      FigmaStyleModel._fromJson(json);
}