import 'package:flutter/widgets.dart';
import 'package:pheno_ui/animation/transition_animation.dart';
import 'package:pheno_ui/interface/data/entry.dart';
import 'package:pheno_ui/interface/data/provider.dart';
import 'package:pheno_ui/interface/data/screen_spec.dart';

import '../widgets/figma_screen_renderer.dart';


class FigmaScreens {
  static final FigmaScreens _sharedInstance = FigmaScreens._internal();
  final Map<String, PhenoDataEntry> screens = {};
  final Map<String, WidgetBuilder> screenBuilders = {};
  final Map<String, TransitionAnimation> transitions = {
    'default_screen': TransitionAnimationLibrary.slideInFromRight.animation,
    'default_popup': TransitionAnimationLibrary.slideInFromBottom.animation,
  };

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
      return PageRouteBuilder(
          settings: RouteSettings(name: 'unknown_screen_$uid'),
          pageBuilder: (_, __, ___) => Container(
            color: const Color(0xFFFF00FF),
            child: Center(
              child: Text('Unknown screen: $uid'),
            ),
          ),
      );
    }

    Map<String, dynamic>? args = settings.arguments as Map<String, dynamic>?;
    bool isPopup = args != null && args['type'] is String && args['type'] == 'popup';
    final transition = transitions[isPopup ? 'default_popup' : 'default_screen']!;
    return PageRouteBuilder(
      settings: RouteSettings(name: uid, arguments: settings.arguments),
      pageBuilder: (context, _, __) => builder(context),
      transitionsBuilder: transition.transitionBuilder,
      transitionDuration: transition.duration,
      reverseTransitionDuration: transition.reverseDuration,
      opaque: !isPopup,
    );
  }
}