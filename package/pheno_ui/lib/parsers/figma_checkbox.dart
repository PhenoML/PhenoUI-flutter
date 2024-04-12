import 'package:flutter/widgets.dart';
import 'package:pheno_ui/parsers/figma_component.dart';
import '../models/figma_component_model.dart';
import '../widgets/figma_node_old.dart';
import 'figma_form.dart';
import 'tools/figma_dimensions.dart';

class FigmaCheckboxParser extends FigmaComponentParser {
  const FigmaCheckboxParser(): super();

  @override
  String get type => 'figma-checkbox';

  @override
  Widget parse(BuildContext context, FigmaComponentModel model) {
    GlobalKey key = GlobalKey();
    Widget widget = FigmaNodeOld.withContext(context,
      model: model,
      child: GestureDetector(
        onTap: () {
          print('onTap ${model.info?.name}');
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
  FocusNode? focusNode;
  String _state = 'unchecked';
  bool get checked => _state == 'checked';
  set checked(bool value) {
    _state = value ? 'checked' : 'unchecked';
    setVariant(userData.get('state'), userData.get(_state));
    var form = FigmaFormInterface.maybeOf(context);
    if (form != null) {
      form.inputValueChanged(userData.get('id'), checked);
    }
  }

  @override
  void initState() {
    super.initState();
    var form = FigmaFormInterface.maybeOf(context, listen: false);
    if (form != null) {
      focusNode = form.registerInput(userData.get('id'), checked);
    }
  }

  @override
  void initVariant() {
    setVariant(userData.get('state'), userData.get(_state));
  }

  @override
  Widget build(BuildContext context) {
    var form = FigmaFormInterface.maybeOf(context, listen: false);
    if (form != null && !form.shouldDisplayInput(userData.get('id'))) {
      return const SizedBox();
    }
    return super.build(context);
  }
}