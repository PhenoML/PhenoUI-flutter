import 'package:flutter/widgets.dart';

class FigmaFormInput<T> {
  final FocusNode node;
  final String id;
  T value;
  Type get type => value.runtimeType;
  FigmaFormInput(this.node, this.id, this.value);
}

class FigmaFormNotification extends Notification {

}

class FigmaFormRegisterInputNotification extends FigmaFormNotification {
  final FigmaFormInput input;
  FigmaFormRegisterInputNotification(this.input);
}

class FigmaFormInputValueChangedNotification extends FigmaFormNotification {
  final FigmaFormInput input;
  FigmaFormInputValueChangedNotification(this.input);
}

class FigmaFormInputEditingCompleteNotification extends FigmaFormNotification {
  final FigmaFormInput input;
  FigmaFormInputEditingCompleteNotification(this.input);
}

class FigmaFormInputSubmittedNotification extends FigmaFormNotification {
  final FigmaFormInput input;
  FigmaFormInputSubmittedNotification(this.input);
}

