import 'package:flutter/widgets.dart';
import 'package:pheno_ui/widgets/figma_frame.dart';

class FigmaButton extends FigmaFrame {
  const FigmaButton({
    required super.model,
    super.childrenContainer,
    super.key
  });

  static FigmaButton fromJson(Map<String, dynamic> json) {
    return FigmaFrame.fromJson(json, FigmaButton.new);
  }

  @override
  Widget buildFigmaNode(BuildContext context) {
    String id = model.userData.maybeGet('id') ?? model.info.name!;

    onTap() {
      final notification = ButtonNotification(id, model.userData.get('context'));
      notification.dispatch(context);
    }

    return GestureDetector(
      onTap: onTap,
      child: super.buildFigmaNode(context),
    );
  }
}

class ButtonNotification extends Notification {
  final String id;
  final Map<String, dynamic> data;
  const ButtonNotification(this.id, this.data);
}

