import 'package:flutter/material.dart';
import '../models/figma_dimensions_model.dart';
import '../tools/figma_enum.dart';
import '../models/figma_text_model.dart';
import 'figma_component.dart';
import 'stateless_figma_node.dart';

class FigmaText extends StatelessFigmaNode<FigmaTextModel> {
  const FigmaText({required super.model, super.key});

  static FigmaText fromJson(Map<String, dynamic> json) {
    final FigmaTextModel model = FigmaTextModel.fromJson(json);
    return FigmaText(model: model);
  }

  static List<FigmaTextSegmentModel> textSegmentsFromModel(BuildContext context, FigmaTextModel model, String? Function(BuildContext) getCharacters) {
    final characters = getCharacters(context);
    if (characters is String) {
      var segment = model.segments.first;
      return [FigmaTextSegmentModel.copy(segment, characters: characters)];
    }
    return model.segments;
  }

  static String? getCharactersFromModel(BuildContext context, FigmaTextModel model) {
    if (model.componentRefs != null &&
        model.componentRefs!.containsKey('characters')) {
      String key = model.componentRefs!['characters']!;
      var data = FigmaComponentData.of(context);
      var characters = data.userData.maybeGet(key);
      if (characters is String) {
        return characters;
      }
    }
    return null;
  }

  List<FigmaTextSegmentModel> getTextSegments(BuildContext context, String? Function(BuildContext) getCharacters) {
    return textSegmentsFromModel(context, model, getCharacters);
  }

  String? getCharacters(BuildContext context) {
    return getCharactersFromModel(context, model);
  }

  @override
  Widget buildFigmaNode(BuildContext context) {
    var modelSegments = getTextSegments(context, getCharacters);
    List<TextSpan> segments = modelSegments.map((m) => m.span).toList();

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

    Widget widget;

    if (model.userData.maybeGet('selectable') == true) {
      widget = SelectionArea(
        child: Builder(
          builder: (context) {
            return MouseRegion(
              cursor: SystemMouseCursors.text,
              child: RichText(
                text: TextSpan(
                  children: segments,
                ),
                textAlign: TextAlign.values.convertDefault(model.alignHorizontal, TextAlign.left),
                selectionRegistrar: SelectionContainer.maybeOf(context),
                selectionColor: model.segments.first.color.withAlpha(64),
                maxLines: 1, // sorry future Dario
              ),
            );
          }
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

    return Align(
      widthFactor: dimensions.widthMode == FigmaDimensionsSizing.hug ? 1.0 : null,
      heightFactor: dimensions.heightMode == FigmaDimensionsSizing.hug ? 1.0 : null,
      alignment: alignment,
      child: widget,
    );
  }
}
