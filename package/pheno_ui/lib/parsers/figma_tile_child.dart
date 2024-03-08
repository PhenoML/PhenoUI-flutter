import 'package:flutter/widgets.dart';
import 'package:pheno_ui/models/figma_tile_child_model.dart';
import 'package:pheno_ui/parsers/tools/figma_dimensions.dart';
import '../models/figma_node_model.dart';
import '../pheno_ui.dart';
import '../widgets/figma_frame_layout_none.dart';
import '../widgets/figma_node.dart';

class FigmaTileChildParser extends MiraiParser<FigmaTileChildModel> {
const FigmaTileChildParser();

  @override
  FigmaTileChildModel getModel(Map<String, dynamic> json) => FigmaTileChildModel.fromJson(json);

  @override
  String get type => 'figma-tile-child';

  @override
  Widget parse(BuildContext context, FigmaTileChildModel model) {
    // for now throw if vertical tile enabled or center horizontal direction
    if (model.userData.maybeGet('vertical') == true) {
      throw Exception('Vertical tile is not supported');
    }
    if (model.horizontalDirection == FigmaTileChildHorizontalDirection.center) {
      throw Exception('Center horizontal direction is not supported');
    }

    Widget widget = LayoutBuilder(builder: (context, constraints) {
      List<Widget> children = [];

      if (model.horizontalDirection == FigmaTileChildHorizontalDirection.right) {
        double start = model.childPosition.dx;
        int count = ((constraints.maxWidth - start) / model.childSize.width).ceil();

        var parser = MiraiRegistry.instance.getParser(model.child['type'])!;
        for (int i = 0; i < count; i++) {
          model.child['dimensions']['self']['x'] = start + i * model.childSize.width;
          FigmaNodeModel childModel = parser.getModel(model.child);
          children.add(parser.parse(context, childModel));
        }
        model.child['dimensions']['self']['x'] = model.childPosition.dx;
      } else {
        double start = constraints.maxWidth - (model.dimensions!.self.width - model.childPosition.dx);
        int count = (start / model.childSize.width).ceil() + 1;

        var parser = MiraiRegistry.instance.getParser(model.child['type'])!;
        for (int i = 0; i < count; i++) {
          model.child['dimensions']['self']['x'] = model.childPosition.dx - i * model.childSize.width;
          FigmaNodeModel childModel = parser.getModel(model.child);
          children.add(parser.parse(context, childModel));
        }
        model.child['dimensions']['self']['x'] = model.childPosition.dx;
      }

      Widget child = FigmaFrameLayoutNone.layoutWithChildren(model.dimensions!.self, children);
      return Container(
        constraints: model.dimensions!.self.sizeConstraints,
        child: child,
      );
    });

    widget = FigmaNode.withContext(context,
      model: model,
      child: widget,
    );

    return dimensionWrapWidget(widget, model.dimensions!, model.parentLayout!);
  }
}