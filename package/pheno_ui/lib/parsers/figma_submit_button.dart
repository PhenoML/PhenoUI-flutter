import 'package:flutter/widgets.dart';
import 'package:mirai/mirai.dart';
import 'package:pheno_ui/models/figma_simple_child_model.dart';
import 'package:pheno_ui/parsers/figma_form.dart';
import '../models/figma_frame_model.dart';
import '../models/figma_nav_button_model.dart';

class FigmaSubmitButtonParser extends MiraiParser<FigmaSimpleChildModel> {
  const FigmaSubmitButtonParser();

  @override
  FigmaSimpleChildModel getModel(Map<String, dynamic> json) => FigmaSimpleChildModel.fromJson(json);

  @override
  String get type => 'figma-submit-button';

  @override
  Widget parse(BuildContext context, FigmaSimpleChildModel model) {
    onTap() {
      FigmaFormInterface.maybeOf(context)?.submit(model.userData.maybeGet('context'));
    }

    var frameModel = FigmaFrameModel.fromJson(model.child, (context, _, builder) => GestureDetector(onTap: onTap, child: builder(context)));
    var parser = MiraiRegistry.instance.getParser(model.child['type']);
    return parser?.parse(context, frameModel) ?? const SizedBox();
  }
}