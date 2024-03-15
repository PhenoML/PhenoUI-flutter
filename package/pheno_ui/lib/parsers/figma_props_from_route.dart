import 'package:flutter/widgets.dart';
import 'package:mirai/mirai.dart';
import 'package:pheno_ui/models/figma_simple_child_model.dart';

class FigmaPropsFromRouteParser extends MiraiParser<FigmaSimpleChildModel> {
  const FigmaPropsFromRouteParser();

  @override
  FigmaSimpleChildModel getModel(Map<String, dynamic> json) =>
      FigmaSimpleChildModel.fromJson(json);

  @override
  String get type => 'figma-props-from-route';

  @override
  Widget parse(BuildContext context, FigmaSimpleChildModel model) {
    var parser = MiraiRegistry.instance.getParser(model.child['type']);
    if (parser == null) {
      return const SizedBox();
    }
    var childModel = parser.getModel(model.child);

    Map<String, dynamic>? props = model.userData.maybeGet('props');
    if (props is Map<String, dynamic>) {
      var arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments is Map<String, dynamic>) {
        var data = arguments['data'];
        if (data is Map<String, dynamic>) {
          for (var key in props.keys) {
            var value = data[key];
            if (value != null) {
              childModel.userData.set(key, value);
            }
          }
        }
      }
    }
    return parser.parse(context, childModel);
  }
}