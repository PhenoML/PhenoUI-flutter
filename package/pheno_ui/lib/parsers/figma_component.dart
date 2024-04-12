import 'package:flutter/widgets.dart';
import 'package:mirai/mirai.dart';
import 'package:pheno_ui/interface/screens.dart';
import 'package:pheno_ui/models/figma_layout_model.dart';
import 'package:pheno_ui/parsers/tools/figma_dimensions.dart';
import 'package:pheno_ui/parsers/tools/figma_user_data.dart';
import 'package:pheno_ui/widgets/figma_node_old.dart';

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
    Widget widget = FigmaNodeOld.withContext(context,
      model: model,
      child: FigmaComponent(FigmaComponentState.new, model),
    );

    return dimensionWrapWidget(widget, model.dimensions!, model.parentLayout);
  }
}

class FigmaComponentData extends InheritedWidget {
  final FigmaUserData userData;

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

class FigmaComponent<T extends FigmaComponentState> extends StatefulWidget {
  static Future<FigmaComponent> instance<T extends FigmaComponentState>({
    required String component,
    T Function()? stateNew,
    Key? key,
    Map<String, dynamic>? arguments,
  }) async  {
    var spec = await FigmaScreens().provider!.loadComponentSpec(component);
    var userData = FigmaUserData(spec.arguments);
    if (arguments != null) {
      for (var entry in arguments.entries) {
        userData.set(entry.key, entry.value);
      }
    }
    var model = FigmaComponentModel(
      type: 'figma-component-instance',
      widgetType: component,
      userData: userData,
      parentLayout: FigmaLayoutParentValuesModel(),
    );
    return FigmaComponent(stateNew ?? FigmaComponentState.new, model, key: key);
}

  final T Function() stateNew;
  final FigmaComponentModel model;

  const FigmaComponent(this.stateNew, this.model, { super.key });

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => stateNew();
}

class FigmaComponentState extends State<FigmaComponent> {
  late final FigmaUserData userData;

  Map<String, dynamic>? spec;
  Map<String, dynamic>? variants;
  Map<String, dynamic> variantValues = {};
  bool loaded = false;

  @override
  void initState() {
    userData = widget.model.userData;
    loadContent();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (spec == null) {
      return loaded ? Container(
        color: const Color(0xFFFF00FF),
        child: Center(
          child: Text('No spec for ${widget.model.widgetType}'),
        ),
      ) : const SizedBox();
    }

    return FigmaComponentData(
      userData: userData,
      child: Builder(
        builder: (context) {
          return Mirai.fromJson(spec!, context) ?? Container(
            color: const Color(0xFFFF00FF),
            child: Center(
              child: Text('Failed to parse ${widget.model.widgetType}'),
            )
          );
        },
      ),
    );
  }

  void setVariant([String? key, String? value]) {
    if (variants == null || variants!.isEmpty) {
      setState(() {
        spec = null;
      });
      return;
    }

    if (key != null && value != null) {
      variantValues[key] = value;
    }

    String? variant;
    if (variantValues.isNotEmpty) {
      for (String key in variants!.keys) {
        Map<String, dynamic> values = variants![key]['variantProperties'];
        if (values.entries.every((entry) => variantValues[entry.key] == entry.value)) {
          variant = key;
          break;
        }
      }
    }

    variant ??= 'default';

    setState(() {
      spec = variants![variant];
    });
  }

  // this can be overridden by the child class to set its own initial variant
  void initVariant() {
    // use the variant set in the model
    setVariant();
  }

  void loadContent() async {
    if (FigmaScreens().provider == null) {
      throw 'FigmaScreens provider not initialized';
    }
    var component = await FigmaScreens().provider!.loadComponentSpec(widget.model.widgetType);
    variants = component.variants;

    userData.map!.forEach((key, value) {
      var components = key.split(RegExp('#(?!.*#)'));
      if (components.length == 2 && components.last == 'variant') {
        variantValues[components.first] = value;
      }
    });

    loaded = true;
    initVariant();
  }
}
