import 'package:flutter/material.dart';
import 'package:pheno_ui/interface/data/screen_spec.dart';
import 'package:pheno_ui/interface/route_arguments.dart';
import 'package:pheno_ui/pheno_ui.dart';

class FigmaScreenRenderer extends StatefulWidget {
  final Future<PhenoScreenSpec>? future;
  final PhenoScreenSpec? spec;

  const FigmaScreenRenderer({ super.key, this.future, this.spec });

  factory FigmaScreenRenderer.fromFuture(Future<PhenoScreenSpec> future) {
    return FigmaScreenRenderer(future: future);
  }

  factory FigmaScreenRenderer.fromSpec(PhenoScreenSpec spec) {
    return FigmaScreenRenderer(spec: spec);
  }

  @override
  State<FigmaScreenRenderer> createState() => FigmaScreenRendererState();
}


class FigmaScreenRendererState extends State<FigmaScreenRenderer> {
  Widget? child;

  FigmaScreenRendererState();

  @override
  initState() {
    super.initState();
    loadContent();
  }

  loadContent() {
    if (widget.future != null) {
      widget.future!.then((spec) => setState(() {
        child = PhenoUi().fromJson(spec.spec);
      }));
      return;
    } else if (widget.spec != null) {
      setState(() {
        child = PhenoUi().fromJson(widget.spec!.spec);
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (child == null) {
      return const SizedBox();
    }

    var args = ModalRoute.of(context)?.settings.arguments;
    bool isOpaque;
    if (args is RouteArguments) {
      isOpaque = args.type == RouteType.screen;
    } else {
      isOpaque = true;
    }

    // future Dario: once we replace material popups with custom ones, we can
    // remove the isPopup check and the Material widget
    return Material(
      color: isOpaque ? null : Colors.transparent,
      child: child,
    );
  }
}