import 'package:flutter/material.dart';
import '../tools/figma_enum.dart';
import '../models/figma_text_model.dart';
import 'figma_component.dart';
import 'figma_node.dart';

class FigmaText extends StatelessFigmaNode<FigmaTextModel> {
  const FigmaText({required super.model, super.key});

  static FigmaText fromJson(Map<String, dynamic> json) {
    final FigmaTextModel model = FigmaTextModel.fromJson(json);
    return FigmaText(model: model);
  }

  List<FigmaTextSegmentModel> getTextSegments(BuildContext context, FigmaTextModel model) {
    if (model.componentRefs != null &&
        model.componentRefs!.containsKey('characters')) {
      String key = model.componentRefs!['characters']!;
      var data = FigmaComponentData.of(context);
      var characters = data.userData.maybeGet(key);
      if (characters is String) {
        var segment = model.segments.first;
        return [FigmaTextSegmentModel.copy(segment, characters: characters)];
      }
    }
    return model.segments;
  }



  @override
  Widget buildFigmaNode(BuildContext context) {
    // if this is a text field and belongs to a form, check if it should be displayed
    // TODO: Uncomment once FigmaFormInterface is implemented
    // if (model.isTextField) {
    //   var form = FigmaFormInterface.maybeOf(context);
    //   if (form != null) {
    //     String id = model.userData.get('id', context: context);
    //     if (!form.shouldDisplayInput(id)) {
    //       return const SizedBox();
    //     }
    //   }
    // }

    var modelSegments = getTextSegments(context, model);

    List<TextSpan> segments = modelSegments.map((m) => m.span).toList();

    Widget widget;
    if (model.isTextField) {
      String id = model.userData.get('id', context: context);
      // TODO: Uncomment once FigmaFormInterface is implemented, text field should be implemented as a stateful widget
      var form = null; // FigmaFormInterface.maybeOf(context);
      FocusNode? focusNode;
      if (form != null) {
        focusNode = form.registerInput(id, '');
      }

      widget = TextField(
        focusNode: focusNode,
        onTapOutside: (_) => focusNode?.unfocus(),
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

}