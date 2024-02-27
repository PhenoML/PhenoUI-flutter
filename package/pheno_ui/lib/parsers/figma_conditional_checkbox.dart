import 'package:flutter/widgets.dart';
import 'package:pheno_ui/parsers/figma_component.dart';
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
            Navigator.of(context).pushNamed(
              model.userData['push'],
              arguments: model.userData['popup'] ? 'popup' : 'screen',
            ).then((value) {
              if (value != null) {
                var state = key.currentState as FigmaCheckboxState;
                state.checked = value == 'true' ? true : false;
              }
            });
          },
          child: FigmaComponent(FigmaCheckboxState.new, model, key: key),
        )
    );

    return dimensionWrapWidget(widget, model.dimensions!, model.parentLayout);
  }
}