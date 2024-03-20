import '../animation/transition_animation.dart';

enum RouteType {
  screen,
  popup,
  unknown,
}

class RouteArguments {
  final RouteType type;
  final TransitionAnimation transition;
  final Map<String, dynamic>? data;
  RouteArguments({
    required this.type,
    required this.transition,
    this.data,
  });
}
