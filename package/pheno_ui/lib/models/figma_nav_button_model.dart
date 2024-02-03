import '../parsers/tools/figma_enum.dart';
import 'figma_simple_child_model.dart';

enum FigmaNavButtonAction with FigmaEnum {
  pop,
  push,
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

  FigmaNavButtonModel._fromJson(Map<String, dynamic> json)
      :
        action = FigmaNavButtonAction.values.byNameDefault(json['__userData']['action'], FigmaNavButtonAction.pop),
        target = json['__userData']['target'],
        super(child: json['child'] as Map<String, dynamic>);

  factory FigmaNavButtonModel.fromJson(Map<String, dynamic> json) =>
      FigmaNavButtonModel._fromJson(json);
}
