import 'package:flutter/widgets.dart';

import 'figma_form_types.dart';
import 'figma_user_data.dart';

abstract class FigmaFormHandler {
  const FigmaFormHandler();
  bool shouldDisplayInput(String id) => true;
  void onInputRegistered<T>(BuildContext context, Map<String, FigmaFormInput> inputs, FigmaFormInput<T> input) { /* nothing */ }
  void onInputValueChanged<T>(BuildContext context, Map<String, FigmaFormInput> inputs, FigmaFormInput<T> input) { /* nothing */ }
  void onInputEditingComplete<T>(BuildContext context, Map<String, FigmaFormInput> inputs, FigmaFormInput<T> input) { /* nothing */ }
  void onInputSubmitted<T>(BuildContext context, Map<String, FigmaFormInput> inputs, FigmaFormInput<T> input) { /* nothing */ }
  void onSubmit(BuildContext context, Map<String, FigmaFormInput> inputs, FigmaUserData userData, String buttonId, Map<String, dynamic>? buttonData);
}
