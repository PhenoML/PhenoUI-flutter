import 'package:flutter/widgets.dart';

class FigmaFormInput<T> {
  final FocusNode node;
  final String id;
  T value;
  Type get type => value.runtimeType;
  FigmaFormInput(this.node, this.id, this.value);
}
