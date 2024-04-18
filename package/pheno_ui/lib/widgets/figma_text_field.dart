import 'package:flutter/material.dart';

import '../models/figma_text_model.dart';
import 'figma_form.dart';
import 'figma_text.dart';
import 'stateful_figma_node.dart';

class FigmaTextField extends StatefulFigmaNode<FigmaTextModel> {
  const FigmaTextField({required super.model, super.key});

  static FigmaTextField fromJson(Map<String, dynamic> json) {
    final FigmaTextModel model = FigmaTextModel.fromJson(json);
    return FigmaTextField(model: model);
  }

  @override
  StatefulFigmaNodeState createState() => FigmaTextFieldState();
}

class FigmaTextFieldState extends StatefulFigmaNodeState<FigmaTextField> {
  FigmaFormState? form;
  FocusNode? focusNode;
  late final String _id = widget.model.userData.get('id', context: context, listen: false);

  @override
  void initState() {
    super.initState();
    form = FigmaForm.maybeOf(context);
    if (form != null) {
      focusNode = form!.registerInput(_id, '');
    }
  }

  @override
  Widget buildFigmaNode(BuildContext context) {
    // if this text field belongs to a form, check if it should be displayed
    if (form != null) {
      if (!form!.shouldDisplayInput(_id)) {
        return const SizedBox();
      }
    }

    var modelSegments = FigmaText.getTextSegments(context, widget.model);
    List<TextSpan> segments = modelSegments.map((m) => m.span).toList();

    var alignment = Alignment(
        switch (widget.model.alignHorizontal) {
          FigmaTextAlignHorizontal.left => -1.0,
          FigmaTextAlignHorizontal.center => 0.0,
          FigmaTextAlignHorizontal.right => 1.0,
          _ => 0.0,
        },
        switch (widget.model.alignVertical) {
          FigmaTextAlignVertical.top => -1.0,
          FigmaTextAlignVertical.center => 0.0,
          FigmaTextAlignVertical.bottom => 1.0,
        }
    );

    return Align(
      alignment: alignment,
      child: TextField(
        focusNode: focusNode,
        onTapOutside: (_) => focusNode?.unfocus(),
        style: segments[0].style,
        obscureText: widget.model.userData.maybeGet('isPasswordField', context: context) ?? false,
        onChanged: form == null ? null : (value) {
          form!.inputValueChanged(_id, value);
        },
        onEditingComplete: form == null ? null : () {
          form!.inputEditingComplete(_id);
        },
        onSubmitted: form == null ? null : (value) {
          form!.inputSubmitted(_id, value);
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          border: const OutlineInputBorder(borderSide: BorderSide.none),
          hintText: segments[0].text,
          // hintStyle: segments[0].style,
        ),
      ),
    );
  }
}
