import 'package:flutter/widgets.dart';
import '../interface/screens.dart';
import '../models/figma_component_model.dart';
import '../models/figma_dimensions_model.dart';
import '../tools/figma_user_data.dart';
import 'figma_component_variant.dart';
import 'stateful_figma_node.dart';

typedef FigmaComponentModelGetter<M extends FigmaComponentModel> = M Function(Map<String, dynamic> json);
typedef FigmaComponentStateCreator<S extends FigmaComponentState> = S Function();
typedef FigmaComponentConstructor<C extends FigmaComponent, M extends FigmaComponentModel, S extends FigmaComponentState> = C Function({
  required FigmaComponentStateCreator<S> stateNew,
  required M model,
  required Key key,
});

C figmaComponentFromJson<C extends FigmaComponent, M extends FigmaComponentModel, S extends FigmaComponentState>(
    Map<String, dynamic> json,
    FigmaComponentConstructor<C, M, S> constructor,
    FigmaComponentModelGetter<M> modelGetter,
    FigmaComponentStateCreator<S> stateCreator,
) {
  final model = modelGetter(json);
  final GlobalKey<S> stateKey = GlobalKey<S>();
  return constructor(model: model, key: stateKey, stateNew: stateCreator);
}

class FigmaComponent<T extends FigmaComponentModel, S extends FigmaComponentState> extends StatefulFigmaNode<T> {
  final FigmaComponentStateCreator<S> stateNew;

  @override
  GlobalKey<S> get key => super.key as GlobalKey<S>;

  @override
  FigmaDimensionsModel? get dimensions {
    return key.currentState?.dimensions ?? super.dimensions;
  }

  const FigmaComponent({
    required this.stateNew,
    required super.model,
    required super.key
  });

  static FigmaComponent fromJson(Map<String, dynamic> json) {
    return figmaComponentFromJson(json, FigmaComponent.new, FigmaComponentModel.fromJson, FigmaComponentState.new);
  }

  @override
  // ignore: no_logic_in_create_state
  S createState() => stateNew();
}

class FigmaComponentState extends StatefulFigmaNodeState<FigmaComponent> {
  late final FigmaUserData userData;
  late FigmaDimensionsModel dimensions = widget.model.dimensions!;
  final Map<String, dynamic> variantValues = {};
  Map<String, FigmaComponentVariant>? variants;
  FigmaComponentVariant? variant;
  bool loaded = false;

  @override
  void initState() {
    userData = widget.model.userData;
    loadContent();
    super.initState();
  }

  void loadContent() async {
    if (FigmaScreens().provider == null) {
      throw 'FigmaScreens provider not initialized';
    }
    var component = await FigmaScreens().provider!.loadComponentSpec(widget.model.widgetType);
    variants = component.variants.map((k, v) => MapEntry(k, FigmaComponentVariant.fromJson(v)));

    userData.map!.forEach((key, value) {
      var components = key.split(RegExp('#(?!.*#)'));
      if (components.length == 2 && components.last == 'variant') {
        variantValues[components.first] = value;
      }
    });

    loaded = true;
    initVariant();
  }

  // this can be overridden by the child class to set its own initial variant
  void initVariant() {
    // use the variant set in the model
    setVariant();
  }

  void setVariant([String? key, String? value]) {
    if (variants == null || variants!.isEmpty) {
      setState(() {
        variant = null;
        dimensions = widget.model.dimensions!;
      });
      return;
    }

    if (key != null && value != null) {
      variantValues[key] = value;
    }

    if (variantValues.isNotEmpty) {
      for (String key in variants!.keys) {
        Map<String, dynamic> values = variants![key]!.variantProperties;
        if (values.entries.every((entry) => variantValues[entry.key] == entry.value)) {
          variant = variants![key];
          break;
        }
      }
    }

    setState(() {
      variant ??= variants!['default'];
      if (variant != null) {
        // Future Dario:
        // This is going to be an issue because the width and height of the
        // variant should not be forwarded verbatim because the component
        // instance could potentially be scaled. Instead the scale between the
        // original size of the component and the size of the instance should be
        // calculated and applied to the dimensions of the variant.
        dimensions = FigmaDimensionsModel.copy(widget.model.dimensions!,
          width: variant!.model.dimensions!.width,
          height: variant!.model.dimensions!.height,
        );
      } else {
        dimensions = widget.model.dimensions!;
      }
    });
  }

  @override
  Widget buildFigmaNode(BuildContext context) {
    if (variant == null) {
      return loaded ? Container(
        color: const Color(0xFFFF00FF),
        child: Center(
          child: Text('No spec for ${widget.model.widgetType}'),
        ),
      ) : const SizedBox();
    }

    return FigmaComponentData(
      userData: userData,
      child: variant ?? Container(
        color: const Color(0xFFFF00FF),
        child: Center(
          child: Text('Failed to parse ${widget.model.widgetType}'),
        )
      ),
    );
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
  bool updateShouldNotify(covariant FigmaComponentData oldWidget) {
    return oldWidget.userData != userData;
  }
}
