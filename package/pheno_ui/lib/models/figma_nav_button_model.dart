import '../parsers/tools/figma_enum.dart';
import 'figma_simple_child_model.dart';

enum FigmaNavButtonAction with FigmaEnum {
  pop,
  push,
  popup,
  replace,
  ;
  @override
  get figmaName => _figmaName;
  final String? _figmaName;
  const FigmaNavButtonAction([this._figmaName]);
}

class FigmaNavButtonModel extends FigmaSimpleChildModel {
  final FigmaNavButtonAction action;
  final String? target;

  FigmaNavButtonModel.fromJson(Map<String, dynamic> json)
      :
        action = FigmaNavButtonAction.values.byNameDefault(json['__userData']['action'], FigmaNavButtonAction.pop),
        target = json['__userData']['target'],
        super.fromJson(json);
}
