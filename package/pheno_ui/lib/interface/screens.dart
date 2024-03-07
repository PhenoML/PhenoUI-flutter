import 'package:flutter/material.dart';
import 'package:pheno_ui/interface/data/entry.dart';
import 'package:pheno_ui/interface/data/provider.dart';
import 'package:pheno_ui/interface/data/screen_spec.dart';
import 'package:pheno_ui/interface/strapi.dart';

import '../widgets/figma_screen_renderer.dart';


class FigmaScreens {
  static final FigmaScreens _sharedInstance = FigmaScreens._internal();
  late final PhenoDataProvider provider;
  final Map<String, PhenoDataEntry> screens = {};
  final Map<String, PhenoScreenSpec> screenSpecCache = {};
  final Map<String, WidgetBuilder> screenBuilders = {};
  bool _initialized = false;
  get initialized => _initialized;

  factory FigmaScreens() {
    return _sharedInstance;
  }

  FigmaScreens._internal();

  Future<void> init(PhenoDataProvider provider) async {
    this.provider = provider;
    var screens = await this.provider.getScreenList();
    for (var screen in screens) {
      print('id:${screen.id} uid:${screen.uid}');
      this.screens[screen.uid] = screen;
    }
    _initialized = true;
  }

  void registerScreenBuilder(String uid, WidgetBuilder builder) {
    screenBuilders[uid] = builder;
  }

  WidgetBuilder? getScreenBuilder(String uid) {
    if (screenBuilders.containsKey(uid)) {
      return screenBuilders[uid]!;
    }

    if (screenSpecCache.containsKey(uid)) {
      return (context) => FigmaScreenRenderer.fromSpec(screenSpecCache[uid]!);
    }

    if (screens.containsKey(uid)) {
      return (context) => FigmaScreenRenderer.fromFuture(getScreenSpec(uid));
    }

    return null;
  }

  Future<PhenoScreenSpec> getScreenSpec(String uid) async {
    if (screenSpecCache.containsKey(uid)) {
      return screenSpecCache[uid]!;
    }

    var spec = await provider.loadScreenLayout(screens[uid]!.id);
    screenSpecCache[uid] = spec;
    return spec;
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