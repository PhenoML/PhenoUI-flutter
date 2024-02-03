import 'package:flutter/widgets.dart';
import 'package:mirai/mirai.dart';
import 'package:pheno_ui/interface/strapi.dart';

class FigmaScreenRenderer extends StatefulWidget {
  final Future<StrapiScreenSpec>? future;
  final StrapiScreenSpec? spec;

  const FigmaScreenRenderer({ super.key, this.future, this.spec });

  factory FigmaScreenRenderer.fromFuture(Future<StrapiScreenSpec> future) {
    return FigmaScreenRenderer(future: future);
  }

  factory FigmaScreenRenderer.fromSpec(StrapiScreenSpec spec) {
    return FigmaScreenRenderer(spec: spec);
  }

  @override
  State<FigmaScreenRenderer> createState() => RenderLayoutState();
}


class RenderLayoutState extends State<FigmaScreenRenderer> {
  StrapiScreenSpec? spec;

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

    return Mirai.fromJson(spec!.spec, context) ?? const SizedBox();
  }
}