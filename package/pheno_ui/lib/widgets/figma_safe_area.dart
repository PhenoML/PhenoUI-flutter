import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:pheno_ui/widgets/figma_component.dart';
import '../models/figma_component_model.dart';
import '../models/figma_frame_model.dart';
import 'figma_button.dart';
import 'figma_frame.dart';
import 'stateful_figma_node.dart';

class FigmaSafeArea extends StatefulFigmaNode<FigmaFrameModel> {
  const FigmaSafeArea({
    required super.model,
    super.key
  });

  static FigmaSafeArea fromJson(Map<String, dynamic> json) {
    return FigmaFrame.fromJson(json, FigmaSafeArea.new);
  }

  @override
  StatefulFigmaNodeState createState() => FigmaSafeAreaState();
}

class FigmaSafeAreaState extends StatefulFigmaNodeState<FigmaSafeArea>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  double bottomInset = 0.0;
  double yOffset = 0.0;
  double oldYOffset = 0.0;
  FocusNode? focusNode;
  double focusNodeY = 0.0;

  void updateFocusNode(FocusNode? node, double screenHeight) {
    if (node == focusNode) {
      return;
    }
    focusNode = node;
    if (focusNode != null) {
      BuildContext? context = focusNode!.context;
      if (context != null) {
        RenderBox box = context.findRenderObject() as RenderBox;
        Offset position = box.localToGlobal(Offset(box.size.width * 0.5, box.size.height * 0.5));
        focusNodeY = position.dy + yOffset;
        if (bottomInset != 0.0) {
          double center = (screenHeight - bottomInset) * 0.5;
          double newOffset = min(max(focusNodeY - center, 0.0), bottomInset);
          animateOffset(yOffset, newOffset);
        }
      }
    } else {
      focusNodeY = 0.0;
    }
  }

  void animateOffset(double from, double to) {
    controller.addListener(() {
      double t = Curves.easeOutSine.transform(controller.value);
      setState(() {
        yOffset = from + (to - from) * t;
        oldYOffset = yOffset;
      });
    });

    controller.forward();
  }

  void updateBottomInset(double bottom, double screenHeight) {
    if (bottom != bottomInset) {
      if (focusNode == null) {
        if (yOffset != 0.0) {
          yOffset = oldYOffset * (bottom / bottomInset);
        }
        if (bottom == 0.0) {
          yOffset = 0.0;
          oldYOffset = 0.0;
          bottomInset = bottom;
        }
      } else {
        bottomInset = bottom;
        double center = (screenHeight - bottomInset) * 0.5;
        yOffset = min(max(focusNodeY - center, 0.0), bottomInset);
        oldYOffset = yOffset;
      }
    }
  }

  void handleFocusChange() {
    if (context.mounted) {
      double screenHeight = MediaQuery.of(context).size.height;
      updateFocusNode(
        FocusScope.of(context, createDependency: false).focusedChild,
        screenHeight,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    controller.addStatusListener((status) {
      if(status == AnimationStatus.completed) {
        controller.clearListeners(); // we could also save all listeners and remove them one by one
        controller.reset();
      }
    });

    FocusManager.instance.addListener(handleFocusChange);
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(handleFocusChange);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget buildFigmaNode(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    updateBottomInset(MediaQuery.of(context).viewInsets.bottom, screenHeight);

    Matrix4 offset = Matrix4.identity()..translate(0.0, -yOffset, 0.0);

    return Transform(
      transform: offset,
      child: SafeArea(
        maintainBottomViewPadding: true,
        child: FigmaFrame.buildFigmaFrame(context, widget.model),
      ),
    );
  }
}
