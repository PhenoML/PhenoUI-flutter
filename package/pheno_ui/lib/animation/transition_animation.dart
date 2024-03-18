import 'package:flutter/widgets.dart';
import 'package:pheno_ui/animation/multi_tween.dart';
import 'package:pheno_ui/animation/transition_player.dart';

class TransitionAnimation {
  final MultiTween primaryForward;
  final MultiTween primaryReverse;
  final MultiTween? secondaryForward;
  final MultiTween? secondaryReverse;

  final Duration duration;
  final Duration reverseDuration;

  const TransitionAnimation({
    required this.primaryForward,
    MultiTween? primaryReverse,
    this.secondaryForward,
    MultiTween? secondaryReverse,
    this.duration = const Duration(milliseconds: 300),
    this.reverseDuration = const Duration(milliseconds: 300),
  }) : primaryReverse = primaryReverse ?? primaryForward,
       secondaryReverse = secondaryReverse ?? secondaryForward;

  Widget transitionBuilder(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    if (secondaryAnimation.status == AnimationStatus.forward || secondaryAnimation.status == AnimationStatus.completed) {
      if (secondaryForward != null) {
        final tween = secondaryAnimation.status == AnimationStatus.forward ? secondaryForward! : secondaryReverse!;
        final multiAnimation = secondaryAnimation.drive(tween);
        return TransitionPlayer(animation: multiAnimation, child: child);
      }
      return child;
    }

    final tween = animation.status == AnimationStatus.forward ? primaryForward : primaryReverse;
    final multiAnimation = animation.drive(tween);
    return TransitionPlayer(animation: multiAnimation, child: child);
  }
}