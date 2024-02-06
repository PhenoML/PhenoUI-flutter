import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mirai/mirai.dart';
import 'package:pheno_ui/widgets/figma_node.dart';
import './tools/figma_dimensions.dart';
import '../models/figma_text_model.dart';
import '../parsers/tools/figma_enum.dart';


class FigmaTextParser extends MiraiParser<FigmaTextModel> {
  const FigmaTextParser();

  @override
  FigmaTextModel getModel(Map<String, dynamic> json) => FigmaTextModel.fromJson(json);

  @override
  String get type => 'figma-text';

  @override
  Widget parse(BuildContext context, FigmaTextModel model) {
    Widget widget = LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      double scale = 1.0;
      if (constraints.hasBoundedWidth && constraints.hasBoundedHeight) {
        scale = min(constraints.maxWidth / model.dimensions.self.width, constraints.maxHeight / model.dimensions.self.height);
      } else if (constraints.hasBoundedWidth) {
        scale = constraints.maxWidth / model.dimensions.self.width;
      } else if (constraints.hasBoundedHeight) {
        scale = constraints.maxHeight / model.dimensions.self.height;
      }

      List<TextSpan> segments = model.segments.map((m) {
        var text = switch (m.textCase) {
          FigmaTextCase.upper => m.characters.toUpperCase(),
          FigmaTextCase.lower => m.characters.toLowerCase(),
          FigmaTextCase.original => m.characters,
          _ => throw 'Unsupported textCase: ${m.textCase.name}'
        };

        var decoration = switch (m.decoration) {
          FigmaTextDecoration.none => TextDecoration.none,
          FigmaTextDecoration.strikethrough => TextDecoration.lineThrough,
          FigmaTextDecoration.underline => TextDecoration.underline,
        };

        var height = switch (m.lineHeight.unit) {
          FigmaTextUnit.pixels => (m.lineHeight.value as double) / m.size * scale,
          FigmaTextUnit.percent => (m.lineHeight.value as double) * 0.01,
          FigmaTextUnit.auto => 1.2 // good enough, sorry future Dario :/
        };

        var spacing = switch (m.letterSpacing.unit) {
          FigmaTextUnit.pixels => (m.letterSpacing.value as double),
          FigmaTextUnit.percent => (m.letterSpacing.value as double) * m.size * 0.01,
          FigmaTextUnit.auto => null
        };

        var style = GoogleFonts.getFont(m.name.family, textStyle:  TextStyle(
          fontSize: m.size * scale,
          fontFamily: m.name.family,
          fontStyle: FontStyle.values.convert(m.name.style),
          fontWeight: m.weight,
          decoration: decoration,
          height: height,
          letterSpacing: spacing,
          color: m.color,
          // list options not supported natively by flutter, implement if needed...
          // indentation is not supported natively by flutter and the figma documentation is not clear as to how it works, implement in the future if needed...
          // hyperlinks are not straight forward and require dependencies, implement in the future if needed
        ));

        return TextSpan(
          text: text,
          style: style,
        );
      }).toList();

      return RichText(
        text: TextSpan(
          children: segments,
        ),
        overflow: TextOverflow.visible,
        textAlign: TextAlign.values.convertDefault(model.alignHorizontal, TextAlign.left),
      );
    });


    // widget = FittedBox(
    //   fit: BoxFit.contain,
    //   child: widget,
    // );

    widget = FigmaNode(
      info: model.info,
      dimensions: model.dimensions.self,
      child: widget,
    );

    return dimensionWrapWidget(widget, model.dimensions, model.parentLayout);
  }
}