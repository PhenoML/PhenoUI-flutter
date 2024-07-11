import 'package:flutter/widgets.dart';

import '../models/figma_component_model.dart';
import '../tools/figma_form_types.dart';
import 'figma_component.dart';
import 'figma_form.dart';

class FigmaSlider extends FigmaComponent with FigmaFormWidget {
  const FigmaSlider({
    required super.stateNew,
    required super.model,
    required super.key
  });

  static FigmaComponent fromJson(Map<String, dynamic> json) {
    return figmaComponentFromJson(json, FigmaSlider.new, FigmaComponentModel.fromJson, FigmaSliderState.new);
  }

  static FigmaSliderInterface? maybeOf(BuildContext context, { bool listen = true }) {
    if (listen) {
      return context.dependOnInheritedWidgetOfExactType<FigmaSliderInterface>();
    }
    return context.getInheritedWidgetOfExactType<FigmaSliderInterface>();
  }

  static FigmaSliderInterface of(BuildContext context) {
    FigmaSliderInterface? interface = maybeOf(context);
    assert(() {
      if (interface == null) {
        throw FlutterError(
          'FigmaForm operation requested with a context that does not include a FigmaForm.\n'
              'The context used to access the state must be that of a widget that'
              'is a descendant of a FigmaForm widget.',
        );
      }
      return true;
    }());
    return interface!;
  }

}

class FigmaSliderState extends FigmaComponentState {
  FigmaFormInterface? form;
  late final double minValue = widget.model.userData.get('minValue', context: context, listen: false).toDouble();
  late final double maxValue = widget.model.userData.get('maxValue', context: context, listen: false).toDouble();
  late final double increment = widget.model.userData.get('increment', context: context, listen: false).toDouble();
  late final Map<String, dynamic>? labels = widget.model.userData.get('labels', context: context, listen: false);

  final Matrix4 _transform = Matrix4.identity();
  late final String _id = widget.model.userData.get('id', context: context, listen: false);

  bool _hasInputArea = false;

  double? _x;
  double _xMax = 0;
  double _xMouseOffset = 0;
  double get x => _x ?? 0;
  set x(double value) {
    if (value < 0) {
      value = 0;
    } else if (value > _xMax) {
      value = _xMax;
    }

    _x = value;
    _transform.setTranslationRaw(-(_xMax - x), 0, 0);
    setValuePercent(x / _xMax);
  }

  double? _value;
  double get value => _value ?? 0;
  set value(double value) {
    if (_value != value) {
      _value = value;
      if (form != null) {
        form!.inputValueChanged(_id, value);
      }
    }
  }

  FocusNode? _focusNode;
  FocusNode? get focusNode => _focusNode;
  set focusNode(FocusNode? value) {
    if (_focusNode != value) {
      if (_focusNode != null) {
        _focusNode!.dispose();
      }
      _focusNode = value;
      if (_focusNode != null) {
        _focusNode!.attach(context);
      }
    }
  }

  void setXMax(double xMax) {
    if (_xMax != xMax) {
      _xMax = xMax;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          x = (value - minValue) / (maxValue - minValue) * _xMax;
        });
      });
    }
  }

  void setValuePercent(double percent) {
    double value = minValue + (maxValue - minValue) * percent;
    // clamp value to min and max
    if (value < minValue) {
      value = minValue;
    } else if (value > maxValue) {
      value = maxValue;
    }
    // round the value to the closest increment
    value = (value / increment).round() * increment;
    this.value = value;
  }

  void alignXToValue() {
    x = (value - minValue) / (maxValue - minValue) * _xMax;
  }

  void setXMouseOffset(double xOffset) {
    _xMouseOffset = xOffset;
  }

  void setHasInputArea(bool flag) {
    _hasInputArea = flag;
  }

  @override
  void initState() {
    super.initState();
    form = FigmaForm.maybeOf(context, listen: false);
    _ensureInitBeforeRender();
  }

  void _ensureInitBeforeRender() {
    if (_x != null) {
      setState(() {});
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _ensureInitBeforeRender();
      });
    }
  }

  void onPanDown(DragDownDetails details) {
    setState(() {
      x = details.globalPosition.dx - _xMouseOffset;
    });
  }

  void onPanUpdate(DragUpdateDetails details) {
    setState(() {
      x = details.globalPosition.dx - _xMouseOffset;
    });
  }

  void onPanEnd([DragEndDetails? details]) {
    setState(() {
      alignXToValue();
    });
  }

  @override
  void initVariantData() {
    super.initVariantData();
    if (form != null) {
      form!.registerInput(_id, value).then((value) {
        focusNode = value.$1;
        this.value = value.$2;
      });
    }
  }

  @override
  Widget buildFigmaNode(BuildContext context) {
    Widget widget = super.buildFigmaNode(context);
    if (_x == null) {
      widget = Offstage(child: widget);
    } else if (!_hasInputArea) {
      widget = GestureDetector(
        onPanDown: onPanDown,
        onPanUpdate: onPanUpdate,
        onPanEnd: onPanEnd,
        onPanCancel: onPanEnd,
        child: widget,
      );
    }

    return FigmaSliderInterface(
      setBarLength: setXMax,
      setHorizontalBarOffset: setXMouseOffset,
      setHasInputArea: setHasInputArea,
      onPanDown: onPanDown,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      handleTransform: _transform,
      barTransform: _transform,
      minValue: minValue,
      maxValue: maxValue,
      value: value,
      increment: increment,
      userLabels: labels,
      child: widget,
    );
  }
}

class FigmaSliderInterface extends InheritedWidget {
  final void Function(double) setBarLength;
  final void Function(double) setHorizontalBarOffset;
  final void Function(bool) setHasInputArea;
  final void Function(DragDownDetails) onPanDown;
  final void Function(DragUpdateDetails) onPanUpdate;
  final void Function ([DragEndDetails?]) onPanEnd;
  final Matrix4 handleTransform;
  final Matrix4 barTransform;
  final double minValue;
  final double maxValue;
  final double value;
  final double increment;
  final Map<String, dynamic>? userLabels;

  const FigmaSliderInterface({
    required this.setBarLength,
    required this.setHorizontalBarOffset,
    required this.setHasInputArea,
    required this.onPanDown,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.handleTransform,
    required this.barTransform,
    required this.minValue,
    required this.maxValue,
    required this.value,
    required this.increment,
    required this.userLabels,
    required super.child,
    super.key,
  });

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }
}

class FigmaSliderInterfaceElement extends InheritedElement {
  FigmaSliderInterfaceElement(super.widget);

}
