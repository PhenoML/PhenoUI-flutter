import 'package:flutter/widgets.dart';
import 'package:pheno_ui/animation/multi_tween.dart';
import 'package:pheno_ui/animation/transition_player.dart';

class TransitionAnimation {
  final MultiTween primary;
  final MultiTween primaryReverse;
  final MultiTween? secondary;
  final MultiTween? secondaryReverse;

  final Duration duration;
  final Duration reverseDuration;

  const TransitionAnimation({
    required this.primary,
    MultiTween? primaryReverse,
    this.secondary,
    MultiTween? secondaryReverse,
    this.duration = const Duration(milliseconds: 300),
    this.reverseDuration = const Duration(milliseconds: 300),
  }) : primaryReverse = primaryReverse ?? primary,
       secondaryReverse = secondaryReverse ?? secondary;

  Widget transitionBuilder(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    switch (animation.status) {
      case AnimationStatus.forward:
        return TransitionPlayer(
          animation: animation.drive(primary),
          child: child
        );

      case AnimationStatus.reverse:
        return TransitionPlayer(
          animation: animation.drive(primaryReverse),
          child: child
        );

      default:
        break;
    }

    if (secondary != null) {
      switch (secondaryAnimation.status) {
        case AnimationStatus.forward:
          return TransitionPlayer(
            animation: secondaryAnimation.drive(secondary!),
            child: child
          );

        case AnimationStatus.reverse:
          return TransitionPlayer(
            animation: secondaryAnimation.drive(secondaryReverse!),
            child: child
          );

        default:
          break;
      }
    }

    return child;
  }
}

enum TransitionAnimationLibrary {
  slideInFromRight(TransitionAnimation(
    primary: MultiTweenLibrary.slideInLeft,
    duration: Duration(milliseconds: 300),
    reverseDuration: Duration(milliseconds: 200),
  )),

  slideInFromBottom(TransitionAnimation(
    primary: MultiTweenLibrary.slideInUp,
    duration: Duration(milliseconds: 400),
    reverseDuration: Duration(milliseconds: 300),
  )),

  elasticInFromBottom(TransitionAnimation(
    primary: MultiTweenLibrary.elasticInUp,
    primaryReverse: MultiTweenLibrary.slideInUp,
    duration: Duration(milliseconds: 800),
    reverseDuration: Duration(milliseconds: 300),
  )),

  boundInFromBottom(TransitionAnimation(
    primary: MultiTweenLibrary.bounceInUp,
    primaryReverse: MultiTweenLibrary.slideInUp,
    duration: Duration(milliseconds: 600),
    reverseDuration: Duration(milliseconds: 400),
  )),


  ;
  final TransitionAnimation animation;
  const TransitionAnimationLibrary(this.animation);
}
