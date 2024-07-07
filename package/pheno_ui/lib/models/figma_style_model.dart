import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';
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
  final Gradient? gradient;
  final BorderRadius? borderRadius;
  final Border? border;
  final FigmaStyleBlendMode blendMode;

  FigmaStyleModel._fromJson(Map<String, dynamic> json, this.color, this.gradient) :
    borderRadius = json['border']['radius']['tl'] == null ? null : BorderRadius.only(
      topLeft: Radius.circular(json['border']['radius']['tl'].toDouble()),
      topRight: Radius.circular(json['border']['radius']['tr'].toDouble()),
      bottomLeft: Radius.circular(json['border']['radius']['bl'].toDouble()),
      bottomRight: Radius.circular(json['border']['radius']['br'].toDouble())
    ),
    border = json['border']['color'] == null ? null : FigmaStyleBorder.all(
      color: Color.fromRGBO(
        (json['border']['color']['r'] * 0xff ~/ 1),
        (json['border']['color']['g'] * 0xff ~/ 1),
        (json['border']['color']['b'] * 0xff ~/ 1),
        (json['border']['opacity'] ?? 1.0).toDouble(),
      ),
      width: json['border']['width'].toDouble()
    ),
    blendMode = FigmaStyleBlendMode.values.byNameDefault(json['blendMode'], FigmaStyleBlendMode.passThrough);

  factory FigmaStyleModel.fromJson(Map<String, dynamic> json) {
    Color? color;
    Gradient? gradient;
    if (json['fill'] != null) {
      final fill = json['fill'];
      if (fill['type'] == 'SOLID') {
        final fillColor = fill['color'];
        color = Color.fromRGBO(
          (fillColor['r'] * 0xff ~/ 1),
          (fillColor['g'] * 0xff ~/ 1),
          (fillColor['b'] * 0xff ~/ 1),
          (fill['opacity'] ?? 1.0).toDouble(),
        );
      } else if (fill['type'] == 'GRADIENT_LINEAR') {
        /*
        {
          "type": "GRADIENT_LINEAR",
          "visible": true,
          "opacity": 1,
          "blendMode": "NORMAL",
          "gradientStops": [
            {
              "color": {
                "r": 0.7400000095367432,
                "g": 0,
                "b": 1,
                "a": 1
              },
              "position": 0,
              "boundVariables": {}
            },
            {
              "color": {
                "r": 1,
                "g": 0,
                "b": 0,
                "a": 1
              },
              "position": 0.5,
              "boundVariables": {}
            },
            {
              "color": {
                "r": 1,
                "g": 0.8999999165534973,
                "b": 0,
                "a": 1
              },
              "position": 1,
              "boundVariables": {}
            }
          ],
          "gradientTransform": [
            [
                6.123234262925839e-17,
                1,
                0
            ],
            [
                -1,
                6.123234262925839e-17,
                1
            ]
          ]
        }
         */
        final colors = <Color>[];
        final stops = <double>[];

        for (final stop in fill['gradientStops']) {
          final stopColor = stop['color'];
          colors.add(Color.fromRGBO(
            (stopColor['r'] * 0xff ~/ 1),
            (stopColor['g'] * 0xff ~/ 1),
            (stopColor['b'] * 0xff ~/ 1),
            (stopColor['a'] ?? 1.0).toDouble(),
          ));
          stops.add(stop['position'].toDouble());
        }

        gradient = LinearGradient(
          colors: colors,
          stops: stops,
          // tileMode: TileMode.decal,
          transform: FigmaGradientTransform.fromJson(fill['gradientTransform']),
        );
      }
    }
    return FigmaStyleModel._fromJson(json, color, gradient);
  }
}

class FigmaGradientTransform extends GradientTransform {
  final Matrix4 matrix4;

  const FigmaGradientTransform({
    required this.matrix4,
  });

  factory FigmaGradientTransform.fromJson(List<dynamic> json) {
    Matrix4 matrix = Matrix4.identity();
    matrix.setRow(0, Vector4(json[0][0].toDouble(), json[0][1].toDouble(), json[0][2].toDouble(), 0));
    matrix.setRow(1, Vector4(json[1][0].toDouble(), json[1][1].toDouble(), json[1][2].toDouble(), 0));
    matrix.invert();
    return FigmaGradientTransform(matrix4: matrix);
  }

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final anchor = bounds.center;
    final anchorMatrix = Matrix4.identity()..translate(-anchor.dx, -anchor.dy);
    final centerMatrix = Matrix4.identity()..translate(anchor.dx, anchor.dy);
    final matrix = centerMatrix * matrix4 * anchorMatrix;

    return matrix;
  }
}
