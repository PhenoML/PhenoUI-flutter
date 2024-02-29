import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mirai/mirai.dart';
import 'package:pheno_ui/widgets/figma_node.dart';
import '../models/figma_dimensions_model.dart';
import '../models/figma_layout_model.dart';
import './tools/figma_dimensions.dart';
import '../models/figma_text_model.dart';
import '../parsers/tools/figma_enum.dart';
import 'figma_component.dart';
import 'figma_form.dart';


class FigmaTextParser extends MiraiParser<FigmaTextModel> {
  const FigmaTextParser();

  @override
  FigmaTextModel getModel(Map<String, dynamic> json) => FigmaTextModel.fromJson(json);

  @override
  String get type => 'figma-text';

  Widget buildWidgetWithScale(BuildContext context, FigmaTextModel model, double scaleX, double scaleY) {
    double scale = min(scaleX, scaleY);

    var modelSegments = model.segments;

    if (model.componentRefs != null && model.componentRefs!.containsKey('characters')) {
      String key = model.componentRefs!['characters']!;
      var data = FigmaComponentData.of(context);
      var characters = data.userData.maybeGet(key);
      if (characters is String) {
        var segment = modelSegments.first;
        modelSegments = [FigmaTextSegmentModel.copy(segment, characters: characters)];
      }
    }

    List<TextSpan> segments = modelSegments.map((m) {
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
        FigmaTextUnit.pixels => (m.lineHeight.value as double) / (m.size * scale),
        FigmaTextUnit.percent => (m.lineHeight.value as double) * 0.01,
        FigmaTextUnit.auto => 1.0, // good enough, sorry future Dario :/
      };

      var spacing = switch (m.letterSpacing.unit) {
        FigmaTextUnit.pixels => (m.letterSpacing.value as double) * scale,
        FigmaTextUnit.percent => (m.letterSpacing.value as double) * m.size * 0.01 * scale,
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

    Widget widget;
    if (model.isTextField) {
      String id = model.userData.get('id', context: context);
      var form = FigmaFormInterface.maybeOf(context);
      if (form != null) {
        form.registerInput(id, '');
      }

      widget = TextField(
        style: segments[0].style,
        obscureText: model.userData.maybeGet('isPasswordField', context: context) ?? false,
        onChanged: form == null ? null : (value) {
          form.inputValueChanged(id, value);
        },
        onEditingComplete: form == null ? null : () {
          form.inputEditingComplete(id);
        },
        onSubmitted: form == null ? null : (value) {
          form.inputSubmitted(id, value);
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          border: const OutlineInputBorder(borderSide: BorderSide.none),
          hintText: segments[0].text,
          // hintStyle: segments[0].style,
        ),
      );
    } else {
      widget = RichText(
        text: TextSpan(
          children: segments,
        ),
        overflow: TextOverflow.visible,
        textAlign: TextAlign.values.convertDefault(model.alignHorizontal, TextAlign.left),
      );
    }

    var alignment = Alignment(
        switch (model.alignHorizontal) {
          FigmaTextAlignHorizontal.left => -1.0,
          FigmaTextAlignHorizontal.center => 0.0,
          FigmaTextAlignHorizontal.right => 1.0,
          _ => 0.0,
        },
        switch (model.alignVertical) {
          FigmaTextAlignVertical.top => -1.0,
          FigmaTextAlignVertical.center => 0.0,
          FigmaTextAlignVertical.bottom => 1.0,
        }
    );

    return Align(
      alignment: alignment,
      child: widget,
    );
  }

  @override
  Widget parse(BuildContext context, FigmaTextModel model) {
    Widget widget;
    if (model.parentLayout.mode == FigmaLayoutMode.none && (model.dimensions?.self.constraints.horizontal == FigmaDimensionsConstraintType.scale || model.dimensions?.self.constraints.vertical == FigmaDimensionsConstraintType.scale)) {
      widget = LayoutBuilder(builder: (context, constraints) {
        double scaleX = 1.0;
        double scaleY = 1.0;
        if (model.dimensions?.self.constraints.horizontal == FigmaDimensionsConstraintType.scale && constraints.hasBoundedWidth) {
          scaleX = constraints.maxWidth / model.dimensions!.self.width;
        }
        if (model.dimensions?.self.constraints.vertical == FigmaDimensionsConstraintType.scale && constraints.hasBoundedHeight) {
          scaleY = constraints.maxHeight / model.dimensions!.self.height;
        }
        return buildWidgetWithScale(context, model, scaleX, scaleY);
      });
    } else {
      widget = buildWidgetWithScale(context, model, 1.0, 1.0);
    }


    // widget = FittedBox(
    //   fit: BoxFit.contain,
    //   child: widget,
    // );

    widget = FigmaNode.withContext(context,
      model: model,
      child: widget,
    );

    return dimensionWrapWidget(widget, model.dimensions!, model.parentLayout);
  }
}