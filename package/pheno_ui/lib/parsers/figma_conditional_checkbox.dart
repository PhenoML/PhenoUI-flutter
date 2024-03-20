import 'package:flutter/widgets.dart';
import 'package:pheno_ui/animation/transition_animation.dart';
import 'package:pheno_ui/interface/route_arguments.dart';
import 'package:pheno_ui/parsers/figma_component.dart';
import 'package:pheno_ui/parsers/tools/figma_enum.dart';
import '../models/figma_component_model.dart';
import '../widgets/figma_node.dart';
import 'figma_checkbox.dart';
import 'tools/figma_dimensions.dart';

class FigmaConditionalCheckboxParser extends FigmaComponentParser {
  const FigmaConditionalCheckboxParser(): super();

  @override
  String get type => 'figma-conditional-checkbox';

  @override
  Widget parse(BuildContext context, FigmaComponentModel model) {
    GlobalKey key = GlobalKey();
    Widget widget = FigmaNode.withContext(context,
        model: model,
        child: GestureDetector(
          onTap: () {
            RouteType type = model.userData.get('popup') ? RouteType.popup : RouteType.screen;
            String? transitionName = model.userData.maybeGet('transition');

            var arguments = RouteArguments(
              type: type,
              transition: TransitionLibrary.getTransition(transitionName, type),
              data: model.userData.maybeGet('data'),
            );

            Navigator.of(context).pushNamed(
              model.userData.get('push'),
              arguments: arguments,
            ).then((value) {
              if (value != null) {
                var state = key.currentState as FigmaCheckboxState;
                if (value is String) {
                  state.checked = value == 'true' ? true : false;
                } else if (value is bool) {
                  state.checked = value;
                }
              }
            });
          },
          child: FigmaComponent(FigmaCheckboxState.new, model, key: key),
        )
    );

    return dimensionWrapWidget(widget, model.dimensions!, model.parentLayout);
  }
}