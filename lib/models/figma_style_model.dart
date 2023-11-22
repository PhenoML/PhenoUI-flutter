import 'package:flutter/material.dart';

class FigmaStyleModel {
  final Color? color;
  final double opacity;
  final BorderRadius? borderRadius;

  FigmaStyleModel({
    this.color,
    required this.opacity,
    this.borderRadius
  });

  factory FigmaStyleModel.fromJson(Map<String, dynamic> json) {
    Color? color;
    if (json['color'] != null) {
      color = Color.fromRGBO(
          (json['color']['r'] * 255.0).round(),
          (json['color']['g'] * 255.0).round(),
          (json['color']['b'] * 255.0).round(),
          json['opacity'].toDouble()
      );
    }

    BorderRadius? borderRadius = json['cornerRadius']['tl'] == null ? null : BorderRadius.only(
      topLeft: Radius.circular(json['cornerRadius']['tl'].toDouble()),
      topRight: Radius.circular(json['cornerRadius']['tr'].toDouble()),
      bottomLeft: Radius.circular(json['cornerRadius']['bl'].toDouble()),
      bottomRight: Radius.circular(json['cornerRadius']['br'].toDouble())
    );

    return FigmaStyleModel(
      color: color,
      opacity: json['opacity'].toDouble(),
      borderRadius: borderRadius
    );
  }
}