import '../parsers/tools/figma_enum.dart';
import 'figma_frame_model.dart';

enum FigmaNavButtonAction with FigmaEnum {
  pop,
  push,
  replace,
  unknown,
  ;
  @override
  get figmaName => _figmaName;
  final String? _figmaName;
  const FigmaNavButtonAction([this._figmaName]);
}

class FigmaNavButtonModel extends FigmaFrameModel {
  final FigmaNavButtonAction action;
  final String? target;

  FigmaNavButtonModel.fromJson(Map<String, dynamic> json)
      :
        action = FigmaNavButtonAction.values.byNameDefault(json['__userData']['action'], FigmaNavButtonAction.unknown),
        target = json['__userData']['target'],
        super.fromJson(json);
}
