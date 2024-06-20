import 'package:flutter/widgets.dart';
import '../models/figma_effects_model.dart';
import '../models/figma_node_model.dart';
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
  FigmaDimensionsModel get dimensions {
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

  static Future<FigmaComponent> instance<T extends FigmaComponentState>({
    required String component,
    T Function()? stateNew,
    GlobalKey<T>? key,
    Map<String, dynamic>? arguments,
  }) async  {
    var spec = await FigmaScreens().provider!.loadComponentSpec(component);
    var userData = FigmaUserData(spec.arguments);

    if (arguments != null) {
      for (var entry in arguments.entries) {
        userData.set(entry.key, entry.value);
      }
    }

    key = key ?? GlobalKey<T>();
    var info = FigmaNodeInfoModel(name: component, id: key.toString());

    var model = FigmaComponentModel(
      type: 'figma-component-instance',
      info: info,
      widgetType: component,
      userData: userData,
      dimensions: FigmaDimensionsModel(),
      effects: FigmaEffectsModel(),
      opacity: 1.0,
    );

    return FigmaComponent(
      stateNew: stateNew ?? FigmaComponentState.new,
      model: model,
      key: key
    );
  }

  @override
  // ignore: no_logic_in_create_state
  S createState() => stateNew();
}

class FigmaComponentState extends StatefulFigmaNodeState<FigmaComponent> implements FigmaUserDataDelegate {
  late final FigmaUserData userData;
  late FigmaDimensionsModel dimensions = widget.model.dimensions;
  final Map<String, dynamic> variantValues = {};

  Map<String, FigmaComponentVariant>? variants;
  FigmaComponentVariant? variant;
  bool loaded = false;
  Size variantScale = const Size(1.0, 1.0);

  bool _userDataChanged = false;
  bool get userDataChanged => _userDataChanged;
  set userDataChanged(bool value) {
    if (value != _userDataChanged) {
      if (mounted && value) {
        setState(() {
          _userDataChanged = value;
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _userDataChanged = false
          );
        });
      } else {
        _userDataChanged = value;
      }
    }
  }

  @override
  onUserDataChanged<T>(String _, T __) {
    userDataChanged = true;
  }

  @override
  void initState() {
    userData = widget.model.userData;
    userData.delegate = this;
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

    var initialVariant = _getVariant(null, null);
    if (initialVariant != null) {
      variantScale = Size(
        widget.model.dimensions.width / initialVariant.model.dimensions.width,
        widget.model.dimensions.height / initialVariant.model.dimensions.height,
      );
    }

    loaded = true;
    initVariant();
  }

  // this can be overridden by the child class to set its own initial variant
  void initVariant() {
    // use the variant set in the model
    setVariant();
  }

  FigmaComponentVariant? _getVariant(String? key, String? value) {
    if (variants == null || variants!.isEmpty) {
      return null;
    }

    if (variantValues.isNotEmpty) {
      for (String key in variants!.keys) {
        Map<String, dynamic> values = variants![key]!.variantProperties;
        if (values.entries.every((entry) => variantValues[entry.key] == entry.value)) {
          return variants![key];
        }
      }
    }

    return variants!['default'];
  }

  void setVariant([String? key, String? value]) {
    if (variants == null || variants!.isEmpty) {
      setState(() {
        variant = null;
        dimensions = widget.model.dimensions;
      });
      return;
    }

    if (key != null && value != null) {
      variantValues[key] = value;
    }

    variant = _getVariant(key, value);

    setState(() {
      if (variant != null) {
        dimensions = FigmaDimensionsModel.copy(widget.model.dimensions,
          width: variant!.model.dimensions.width * variantScale.width,
          height: variant!.model.dimensions.height * variantScale.height,
        );
      } else {
        dimensions = widget.model.dimensions;
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
      getUserDataChanged: () => userDataChanged,
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
  final bool Function() getUserDataChanged;

  const FigmaComponentData({
    required this.userData,
    required this.getUserDataChanged,
    required super.child,
    super.key
  });

  static FigmaComponentData? maybeOf(BuildContext context, { bool listen = true }) {
    if (listen) {
      return context.dependOnInheritedWidgetOfExactType<FigmaComponentData>();
    }
    return context.getInheritedWidgetOfExactType<FigmaComponentData>();
  }

  static FigmaComponentData of(BuildContext context, { bool listen = true }) {
    final FigmaComponentData? result = maybeOf(context, listen: listen);
    assert(result != null, 'No FigmaComponentData found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant FigmaComponentData oldWidget) {
    return getUserDataChanged();
  }
}
