import 'package:flutter/widgets.dart';
import 'package:pheno_ui/animation/multi_tween.dart';
import 'package:pheno_ui/animation/step_tween_double.dart';
import 'package:pheno_ui/animation/transition_player.dart';
import 'package:pheno_ui/animation/tween_segment.dart';
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
    bool isPopup = true; //args != null && args['type'] is String && args['type'] == 'popup';
    return PageRouteBuilder(
      settings: RouteSettings(name: uid, arguments: settings.arguments),
      pageBuilder: (context, _, __) => builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        Offset offsetStart, offsetEnd;
        double scaleStart, scaleEnd;
        double offsetTimeStart, offsetTimeEnd;
        double scaleTimeStart, scaleTimeEnd;

        if (secondaryAnimation.status == AnimationStatus.forward || secondaryAnimation.status == AnimationStatus.reverse) {
          offsetStart = Offset.zero;
          offsetEnd = const Offset(-1.0, 0.0);
          scaleStart = 1.0;
          scaleEnd = 0.8;
          offsetTimeStart = 0.05;
          offsetTimeEnd = 1.0;
          scaleTimeStart = 0.0;
          scaleTimeEnd = 0.5;
        } else {
          offsetStart = const Offset(1.0, 0.0);
          offsetEnd = Offset.zero;
          scaleStart = 0.8;
          scaleEnd = 1.0;
          offsetTimeStart = 0.0;
          offsetTimeEnd = 0.95;
          scaleTimeStart = 0.5;
          scaleTimeEnd = 1.0;
        }

        // if (isPopup) {
          var multi = MultiTween();
          multi['offset'] = TweenSegment(
              start: offsetTimeStart,
              end: offsetTimeEnd,
              animatable: Tween(
                  begin: offsetStart,
                  end: offsetEnd
              ).chain(CurveTween(
                  curve: Curves.easeOut
              ))
          );

          multi['scale'] = TweenSegment(
              start: scaleTimeStart,
              end: scaleTimeEnd,
              animatable: Tween(
                  begin: scaleStart,
                  end: scaleEnd
              ).chain(CurveTween(
                  curve: Curves.easeInOut
              ))
          );

          // print('multi: ${multiAnimation.value}');
          // print(animation.status);
          // print(secondaryAnimation.status);

          if (secondaryAnimation.status == AnimationStatus.forward || secondaryAnimation.status == AnimationStatus.reverse) {
            final multiAnimation = secondaryAnimation.drive(MultiTweenLibrary.wiggleOutLeft);
            return TransitionPlayer(animation: multiAnimation, child: child);
          }
          final multiAnimation = animation.drive(MultiTweenLibrary.wiggleInLeft);
          // final multiAnimation = animation.drive(MultiTween.from({
          //   'offset': Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(StepTweenDouble(begin: 0, end: 1)),
          // }));
          return TransitionPlayer(animation: multiAnimation, child: child);
          // return SlideTransition(
          //   position: offsetAnimation,
          //   child: child,
          // );

        // }
        return child;
      },
      transitionDuration: const Duration(milliseconds: 600),
      reverseTransitionDuration: const Duration(milliseconds: 400),
      opaque: !isPopup,
    );
  }
}