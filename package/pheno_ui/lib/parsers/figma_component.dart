import 'package:flutter/widgets.dart';
import 'package:mirai/mirai.dart';
import 'package:pheno_ui/parsers/tools/figma_dimensions.dart';
import 'package:pheno_ui/widgets/figma_node.dart';

import '../interface/strapi.dart';
import '../models/figma_component_model.dart';

class FigmaComponentParser extends MiraiParser<FigmaComponentModel> {
  const FigmaComponentParser();

  @override
  FigmaComponentModel getModel(Map<String, dynamic> json) =>
      FigmaComponentModel.fromJson(json);

  @override
  String get type => 'figma-component-instance';

  @override
  Widget parse(BuildContext context, FigmaComponentModel model) {
    Widget widget = FigmaNode.withContext(context,
      model: model,
      child: FigmaComponent(model),
    );

    return dimensionWrapWidget(widget, model.dimensions!, model.parentLayout);
  }
}

class FigmaComponentData extends InheritedWidget {
  final Map<String, dynamic> userData;

  const FigmaComponentData({required this.userData, required super.child, super.key});

  static FigmaComponentData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FigmaComponentData>();
  }

  static FigmaComponentData of(BuildContext context) {
    final FigmaComponentData? result = maybeOf(context);
    assert(result != null, 'No FigmaComponentData found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    // TODO: implement updateShouldNotify
    return true;
  }
}

class FigmaComponent extends StatefulWidget {
  final FigmaComponentModel model;

  const FigmaComponent(this.model, { super.key });

  @override
  State<StatefulWidget> createState() => FigmaComponentState();
}

class FigmaComponentState extends State<FigmaComponent> {
  Map<String, dynamic>? spec;

  @override void initState() {
    loadContent();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (spec == null) {
      return const SizedBox();
    }

    return FigmaComponentData(
      userData: widget.model.userData,
      child: Builder(
        builder: (context) {
          return Mirai.fromJson(spec!, context) ?? const SizedBox();
        },
      ),
    );
  }

  void loadContent() async {
    var component = await Strapi().loadComponentSpec(Strapi().category, widget.model.widgetType);

    // TODO: implement variants
    widget.model.userData.forEach((key, value) {
      print('key: $key, value: $value');
    });
    String variant = component.defaultVariant;

    setState(() {
      spec = component.variants[variant];
    });
  }
}
