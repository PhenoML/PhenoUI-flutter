import 'package:flutter/material.dart';
import 'package:mirai/mirai.dart';
import 'package:pheno_ui/interface/data/screen_spec.dart';

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
  State<FigmaScreenRenderer> createState() => RenderLayoutState();
}


class RenderLayoutState extends State<FigmaScreenRenderer> {
  PhenoScreenSpec? spec;

  RenderLayoutState();

  @override
  initState() {
    super.initState();
    loadContent();
  }

  loadContent() {
    spec = null;
    if (widget.future != null) {
      widget.future!.then((layout) => setState(() {
        spec = layout;
      }));
      return;
    } else if (widget.spec != null) {
      setState(() {
        spec = widget.spec;
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (spec == null) {
      return const SizedBox();
    }

    var arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    bool isPopup = arguments != null && arguments['type'] is String && arguments['type'] == 'popup';

    // future Dario: once we replace material popups with custom ones, we can
    // remove the isPopup check and the Material widget
    return Material(
      color: isPopup ? Colors.transparent : null,
      child: Mirai.fromJson(spec!.spec, context) ?? const SizedBox(),
    );
  }
}