import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mirai/mirai.dart';
import 'package:phenoui_flutter/models/figma_dimensions_model.dart';
import 'package:phenoui_flutter/models/figma_layout_model.dart';
import 'package:phenoui_flutter/models/figma_text_model.dart';
import 'package:phenoui_flutter/parsers/tools/figma_enum.dart';


class FigmaTextParser extends MiraiParser<FigmaTextModel> {
  const FigmaTextParser();

  @override
  FigmaTextModel getModel(Map<String, dynamic> json) => FigmaTextModel.fromJson(json);

  @override
  String get type => 'figma-text';

  @override
  Widget parse(BuildContext context, FigmaTextModel model) {
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
        FigmaTextUnit.pixels => (m.lineHeight.value as double) / m.size,
        FigmaTextUnit.percent => (m.lineHeight.value as double),
        FigmaTextUnit.auto => 1.2 // good enough, sorry future Dario :/
      };

      var spacing = switch (m.letterSpacing.unit) {
        FigmaTextUnit.pixels => (m.letterSpacing.value as double),
        FigmaTextUnit.percent => (m.letterSpacing.value as double) * m.size,
        FigmaTextUnit.auto => null
      };

      var style = GoogleFonts.getFont(m.name.family, textStyle:  TextStyle(
        fontSize: m.size,
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

    Widget widget = Text.rich(
      TextSpan(
        children: segments,
      ),
      overflow: TextOverflow.visible,
    );

    var dimensions = model.dimensions.self;
    var mode = model.parentLayout.mode;

    var width = switch (dimensions.widthMode) {
      FigmaDimensionsSizing.fixed => dimensions.width,
      FigmaDimensionsSizing.fill => mode == FigmaLayoutMode.horizontal ? null : double.infinity,
      _ => null
    };

    var height = switch (dimensions.heightMode) {
      FigmaDimensionsSizing.fixed => dimensions.height,
      FigmaDimensionsSizing.fill => mode == FigmaLayoutMode.vertical ? null : double.infinity,
      _ => null
    };

    if (width != null || height != null) {
      widget = SizedBox(
        width: width,
        height: height,
        child: widget,
      );
    }

    if (dimensions.widthMode == FigmaDimensionsSizing.hug || dimensions.heightMode == FigmaDimensionsSizing.hug) {
      Axis? constrained;
      if (dimensions.widthMode != FigmaDimensionsSizing.hug) {
        constrained = Axis.horizontal;
      } else if (dimensions.heightMode != FigmaDimensionsSizing.hug) {
        constrained = Axis.vertical;
      }
      widget = UnconstrainedBox(
        constrainedAxis: constrained,
        child: widget,
      );
    }

    if (
          (dimensions.widthMode == FigmaDimensionsSizing.fill && mode == FigmaLayoutMode.horizontal)
          || (dimensions.heightMode == FigmaDimensionsSizing.fill && mode == FigmaLayoutMode.vertical)
    ) {
      widget = Expanded(child: widget);
    }

    return widget;
  }
}