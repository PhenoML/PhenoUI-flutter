import 'package:flutter/material.dart';
import 'package:pheno_ui/tools/figma_enum.dart';

import '../models/figma_text_model.dart';
import '../tools/figma_form_types.dart';
import 'figma_form.dart';
import 'figma_text.dart';
import 'stateful_figma_node.dart';

enum FigmaTextInputType {
  text(TextInputType.text),
  multiline(TextInputType.multiline),
  number(TextInputType.number),
  phone(TextInputType.phone),
  datetime(TextInputType.datetime),
  email(TextInputType.emailAddress),
  url(TextInputType.url),
  visiblePassword(TextInputType.visiblePassword),
  name(TextInputType.name),
  streetAddress(TextInputType.streetAddress),
  none(TextInputType.none),
  ;
  final TextInputType value;
  const FigmaTextInputType(this.value);
}

class FigmaTextField extends StatefulFigmaNode<FigmaTextModel> with FigmaFormWidget {
  final FigmaTextInputType keyboardType;

  const FigmaTextField({
    required this.keyboardType,
    required super.model,
    super.key
  });

  static FigmaTextField fromJson(Map<String, dynamic> json) {
    final FigmaTextModel model = FigmaTextModel.fromJson(json);
    final FigmaTextInputType keyboardType = FigmaTextInputType.values.byNameDefault(model.userData.maybeGet('keyboardType'), FigmaTextInputType.text);
    return FigmaTextField(keyboardType: keyboardType, model: model);
  }

  @override
  StatefulFigmaNodeState createState() => FigmaTextFieldState();
}

class FigmaTextFieldState extends StatefulFigmaNodeState<FigmaTextField> {
  FigmaFormInterface? form;
  FocusNode? focusNode;
  bool _hasInitialValue = false;
  final TextEditingController _controller = TextEditingController();
  late final String _id = widget.model.userData.get('id', context: context, listen: false);

  @override
  void initState() {
    super.initState();
    form = FigmaForm.maybeOf(context, listen: false);
    if (form != null) {
      form!.registerInput(_id, '').then((value) {
        setState(() {
          focusNode = value.$1;
          _controller.text = value.$2;
          _hasInitialValue = true;
        });
      });
    }
  }

  @override
  Widget buildFigmaNode(BuildContext context) {
    if (!_hasInitialValue) {
      return const SizedBox();
    }

    var modelSegments = FigmaText.textSegmentsFromModel(context, widget.model, (context) => FigmaText.getCharactersFromModel(context, widget.model));
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
        controller: _controller,
        keyboardType: widget.keyboardType.value,
        focusNode: focusNode,
        maxLines: widget.model.userData.maybeGet('isMultiline', context: context) == true ? null : 1,
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
          isDense: true,
          contentPadding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
          border: const OutlineInputBorder(borderSide: BorderSide.none),
          hintText: segments[0].text,
          // hintStyle: segments[0].style,
        ),
      ),
    );
  }
}
