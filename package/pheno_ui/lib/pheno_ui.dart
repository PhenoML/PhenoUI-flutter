library pheno_ui;

import 'package:flutter/widgets.dart';
import 'widgets/figma_component.dart';
import 'widgets/figma_frame.dart';
import 'widgets/figma_image.dart';
import 'widgets/figma_nav_button.dart';
import 'widgets/figma_rectangle.dart';
import 'widgets/figma_safe_area.dart';
import 'widgets/figma_scroll_view.dart';
import 'widgets/figma_text.dart';

import 'models/figma_node_model.dart';
import 'widgets/figma_node.dart';

export 'interface/screens.dart';
export 'interface/strapi.dart';
import 'interface/log.dart';

typedef FigmaNodeFactory = FigmaNode Function(Map<String, dynamic>);

class PhenoUi {
  static PhenoUi? _instance;

  final Map<String, FigmaNodeFactory> _nodeTypeMap = {};

  PhenoUi._internal();

  factory PhenoUi() {
    if (_instance == null) {
      throw Exception(
          'PhenoUi not initialized. Call PhenoUi.initialize() first.'
      );
    }
    return _instance!;
  }

  factory PhenoUi.initialize({Map<String, FigmaNodeFactory> nodeTypes = const {}}) {
    if (_instance == null) {
      _instance = PhenoUi._internal();

      Map<String, FigmaNodeFactory> defaultNodeTypes = {
        'figma-frame': FigmaFrame.fromJson,
        'figma-scroll-view': FigmaScrollView.fromJson,
        'figma-text': FigmaText.fromJson,
        'figma-image': FigmaImage.fromJson,
        'figma-safe-area': FigmaSafeArea.fromJson,
        'figma-nav-button': FigmaNavButton.fromJson,
        'figma-component-instance': FigmaComponent.fromJson,
        'figma-rectangle': FigmaRectangle.fromJson,
      };

      // merge the parsers giving priority to the ones passed as argument
      var mergedParsers = { ...defaultNodeTypes, ...nodeTypes };
      _instance!._nodeTypeMap.addAll(mergedParsers);

      return _instance!;
    }

    throw Exception(
        'PhenoUi already initialized. Call PhenoUi() to get the instance.'
    );
  }

  FigmaNode fromJson(Map<String, dynamic> json) {
    // this function should not be called while the widget tree is building
    assert(
      WidgetsBinding.instance.rootElement != null
      && WidgetsBinding.instance.rootElement!.owner != null
      && !WidgetsBinding.instance.rootElement!.owner!.debugBuilding
    );

    var type = json['type'];
    if (_nodeTypeMap.containsKey(type)) {
      return _nodeTypeMap[type]!(json);
    }
    logger.e('Unknown figma node type: $type');
    return _MissingType.fromJson(json);
  }

  List<FigmaNode> fromJsonList(List<dynamic>? json) {
    if (json == null) {
      return [];
    }
    return json.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }
}

class _MissingType extends StatelessFigmaNode {
  const _MissingType({required super.model});

  static _MissingType fromJson(Map<String, dynamic> json) {
    final FigmaNodeModel model = FigmaNodeModel.fromJson(json);
    return _MissingType(model: model);
  }

  @override
  Widget buildFigmaNode(BuildContext context) {
    return Container(
      color: const Color(0xFFFF00FF),
      child: Center(
        child: Text('Unknown figma node type: ${model.type}'),
      ),
    );
  }
}

