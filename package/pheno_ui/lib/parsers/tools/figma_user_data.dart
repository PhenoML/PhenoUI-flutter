

import 'package:flutter/cupertino.dart';
import 'package:pheno_ui/parsers/figma_component.dart';

class FigmaUserData {
  final Map<String, dynamic>? map;

  FigmaUserData(Map<String, dynamic>? map) : map = map == null ? null : {...map};

  void set<T>(String key, T value) {
    if (map == null) {
      throw 'User data map is null';
    }
    if (map!.containsKey(key) && (map![key] is Map<String, dynamic> || map![key]['type'] == 'group')) {
      throw 'Bound values and groups cannot be overwritten';
    }
    map![key] = value;
  }

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
      if (value['type'] == 'binding') {
        if (context == null) {
          throw 'Context is required to parse a component';
        }
        var data = FigmaComponentData.maybeOf(context);
        if (data == null) {
          throw 'FigmaComponentData not found in context';
        }
        return data.userData.maybeGet<T>(value['id'], context: context);
      }

      if (value['type'] == 'group') {
        List<Map<String, dynamic>> properties = (value["properties"] as List).map((e) => e as Map<String, dynamic>).toList();
        Map<String, dynamic> result = {};
        for (var property in properties) {
          if (!property['description'].isEmpty) {
            result[property['description']] = property['value'];
          }
        }
        // set the result back to the map for faster access next time
        map![key] = result;
        return result as T;
      }
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
