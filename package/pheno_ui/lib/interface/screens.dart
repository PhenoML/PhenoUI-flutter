import 'package:flutter/material.dart';
import 'package:pheno_ui/interface/data/entry.dart';
import 'package:pheno_ui/interface/data/provider.dart';
import 'package:pheno_ui/interface/data/screen_spec.dart';

import '../widgets/figma_screen_renderer.dart';


class FigmaScreens {
  static final FigmaScreens _sharedInstance = FigmaScreens._internal();
  final Map<String, PhenoDataEntry> screens = {};
  final Map<String, WidgetBuilder> screenBuilders = {};

  PhenoDataProvider? _provider;
  PhenoDataProvider? get provider => _provider;

  factory FigmaScreens() {
    return _sharedInstance;
  }

  FigmaScreens._internal();

  Future<void> setProvider(PhenoDataProvider provider) async {
    if (_provider != null) {
      if (_provider == provider || (_provider!.sourceId == provider.sourceId && _provider!.category == provider.category)) {
        return;
      }
    }
    _provider = provider;
    await refreshScreens();
  }

  void registerScreenBuilder(String uid, WidgetBuilder builder) {
    screenBuilders[uid] = builder;
  }

  Future<void> refreshScreens() async {
    clearCache();
    if (_provider == null) {
      return;
    }
    var screens = await _provider!.getScreenList(true);
    for (var screen in screens) {
      print('id:${screen.id} uid:${screen.uid}');
      this.screens[screen.uid] = screen;
    }
  }

  void clearCache() {
    screens.clear();
    _provider?.clearCache();
  }

  WidgetBuilder? getScreenBuilder(String uid) {
    if (screenBuilders.containsKey(uid)) {
      return screenBuilders[uid]!;
    }

    if (screens.containsKey(uid)) {
      return (context) => FigmaScreenRenderer.fromFuture(getScreenSpec(uid));
    }

    return null;
  }

  Future<PhenoScreenSpec> getScreenSpec(String uid) async {
    var screen = screens[uid];
    if (screen == null) {
      throw Exception('Unknown screen: $uid');
    }

    return await _provider!.loadScreenLayout(screen.id);
  }

  Route generateRoute(RouteSettings settings) {
    var uid = settings.name!.split('/').last;
    var builder = getScreenBuilder(uid);
    if (builder == null) {
      print('Unknown screen: $uid');
      return MaterialPageRoute(
          settings: const RouteSettings(name: 'unknown_screen'),
          builder: (_) => Container(color: Colors.pink)
      );
    }

    return MaterialPageRoute(
      settings: RouteSettings(name: uid, arguments: settings.arguments),
      builder: builder
    );
  }
}