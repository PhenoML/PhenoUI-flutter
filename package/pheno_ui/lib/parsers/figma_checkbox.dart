import 'package:flutter/widgets.dart';
import 'package:pheno_ui/parsers/figma_component.dart';
import '../models/figma_component_model.dart';
import '../widgets/figma_node.dart';
import 'tools/figma_dimensions.dart';

class FigmaCheckboxParser extends FigmaComponentParser {
  const FigmaCheckboxParser(): super();

  @override
  String get type => 'figma-checkbox';

  @override
  Widget parse(BuildContext context, FigmaComponentModel model) {
    GlobalKey key = GlobalKey();
    Widget widget = FigmaNode.withContext(context,
      model: model,
      child: GestureDetector(
        onTap: () {
          var state = key.currentState as FigmaCheckboxState;
          state.checked = !state.checked;
        },
        child: FigmaComponent(FigmaCheckboxState.new, model, key: key),
      )
    );

    return dimensionWrapWidget(widget, model.dimensions!, model.parentLayout);
  }
}

class FigmaCheckboxState extends FigmaComponentState {
  String _state = 'unchecked';
  bool get checked => _state == 'checked';
  set checked(bool value) {
    _state = value ? 'checked' : 'unchecked';
    setVariant(widget.model.userData.get('state'), widget.model.userData.get(_state));
  }

  @override
  void initVariant() {
    setVariant(widget.model.userData.get('state'), widget.model.userData.get(_state));
  }
}