import 'package:flutter/widgets.dart';
import 'package:pheno_ui/models/figma_node_model.dart';
import 'package:pheno_ui/widgets/figma_button.dart';

import '../models/figma_frame_model.dart';
import 'figma_component.dart';
import 'figma_frame.dart';
import 'stateful_figma_node.dart';

class WidgetAdder extends StatefulFigmaNode<FigmaFrameModel> {
  const WidgetAdder({
    required super.model,
    super.key
  });

  static WidgetAdder fromJson(Map<String, dynamic> json) {
    return FigmaFrame.fromJson(json, WidgetAdder.new);
  }

  @override
  StatefulFigmaNodeState<StatefulFigmaNode<FigmaNodeModel>> createState() => WidgetAdderState();

  static WidgetAdderInherited? maybeOf(BuildContext context, { bool listen = true }) {
    if (listen) {
      return context.dependOnInheritedWidgetOfExactType<WidgetAdderInherited>();
    }
    return context.getInheritedWidgetOfExactType<WidgetAdderInherited>();
  }

  static WidgetAdderInherited of(BuildContext context) {
    WidgetAdderInherited? inherited = maybeOf(context);
    assert(() {
      if (inherited == null) {
        throw FlutterError(
          'WidgetAdder operation requested with a context that does not include a WidgetAdder.\n'
              'The context used to access the state must be that of a widget that'
              'is a descendant of a WidgetAdder widget.',
        );
      }
      return true;
    }());
    return inherited!;
  }
}

class WidgetAdderState extends StatefulFigmaNodeState<WidgetAdder> {
  final List<Widget> _widgets = [];

  bool handleButtonNotification(ButtonNotification notification) {
    String componentName = notification.data['component'];
    FigmaComponent.instance(
        component: componentName,
        arguments: {
          'Label': 'Widget #${_widgets.length + 1}',
        }
    ).then((component) {
      setState(() {
        _widgets.add(component);
      });
    });
    return true;
  }

  @override
  Widget buildFigmaNode(BuildContext context) {
    List<Widget> widgets = List.from(_widgets);

    return NotificationListener<ButtonNotification>(
      onNotification: handleButtonNotification,
      child: WidgetAdderInherited(
        widgets: widgets,
        child: FigmaFrame.buildFigmaFrame(context, widget.model),
      ),
    );
  }
}

class WidgetAdderInherited extends InheritedWidget {
  final List<Widget> widgets;

  const WidgetAdderInherited({
    required this.widgets,
    required super.child,
    super.key
  });

  @override
  bool updateShouldNotify(WidgetAdderInherited oldWidget) {
    return widgets != oldWidget.widgets;
  }
}