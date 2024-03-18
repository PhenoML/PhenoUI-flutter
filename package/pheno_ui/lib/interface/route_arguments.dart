import '../animation/transition_animation.dart';

enum RouteType {
  screen,
  popup,
  unknown,
}

class RouteArguments {
  final RouteType type;
  final TransitionAnimation? animation;
  final Map<String, dynamic>? data;
  RouteArguments({
    required this.type,
    this.animation,
    this.data,
  });
}
