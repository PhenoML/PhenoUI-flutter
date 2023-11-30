import 'package:flutter/material.dart';

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
      border = json['border']['color'] == null ? null : Border.all(
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