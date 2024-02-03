import 'package:flutter/material.dart';
import 'package:pheno_ui/interface/strapi.dart';

import 'figma_screen_renderer.dart';


class FigmaScreens {
  static final FigmaScreens _sharedInstance = FigmaScreens._internal();
  final Map<String, StrapiListEntry> screens = {};
  final Map<String, StrapiScreenSpec> screenSpecCache = {};
  final Map<String, WidgetBuilder> screenBuilders = {};

  factory FigmaScreens() {
    return _sharedInstance;
  }

  FigmaScreens._internal();

  Future<void> init([String strapiCategory = 'product']) async {
    var category = await Strapi().getCategory(strapiCategory);
    print(category.id);
    var screens = await Strapi().getScreenList(category.id);
    for (var screen in screens) {
      print('id:${screen.id} uid:${screen.uid}');
      this.screens[screen.uid] = screen;
    }
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

  Future<StrapiScreenSpec> getScreenSpec(String uid) async {
    if (screenSpecCache.containsKey(uid)) {
      return screenSpecCache[uid]!;
    }

    var spec = await Strapi().loadScreenLayout(screens[uid]!.id);
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