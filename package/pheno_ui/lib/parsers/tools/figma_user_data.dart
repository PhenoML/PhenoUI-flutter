

import 'package:flutter/cupertino.dart';
import 'package:pheno_ui/parsers/figma_component.dart';

class FigmaUserData {
  final Map<String, dynamic>? map;

  FigmaUserData(this.map);

  T get<T>(String key, { BuildContext? context }) {
    if (map == null) {
      throw 'User data map is null';
    }

    var value = maybeGet(key, context: context);
    if (value == null) {
      throw 'Key not found: $key';
    }
    return value as T;
  }

  T? maybeGet<T>(String key, { BuildContext? context }) {
    if (map == null) {
      return null;
    }
    var value = map![key];

    if (value is Map<String, dynamic>) {
      if (context == null) {
        throw 'Context is required to parse a component';
      }
      var data = FigmaComponentData.maybeOf(context);
      if (data == null) {
        throw 'FigmaComponentData not found in context';
      }
      return data.userData.maybeGet<T>(value['id'], context: context);
    }

    return value as T?;
  }

  String getString(String key) {
    return get(key);
  }

  String? maybeGetString(String key) {
    return maybeGet(key);
  }

  int getInt(String key) {
    return get(key);
  }

  int? maybeGetInt(String key) {
    return maybeGet(key);
  }

  double getDouble(String key) {
    return get(key);
  }

  double? maybeGetDouble(String key) {
    return maybeGet(key);
  }

  bool getBool(String key) {
    return get(key);
  }

  bool? maybeGetBool(String key) {
    return maybeGet(key);
  }
}
