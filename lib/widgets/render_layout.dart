import 'package:flutter/material.dart';
import 'package:mirai/mirai.dart';
import 'package:phenoui_flutter/pheno/strapi.dart';
import 'package:phenoui_flutter/widgets/loading_screen.dart';
import 'package:phenoui_flutter/widgets/top_bar.dart';

class RenderLayout extends StatefulWidget {
  final StrapiListEntry entry;

  const RenderLayout({ super.key, required this.entry });

  @override
  State<RenderLayout> createState() => RenderLayoutState();
}


class RenderLayoutState extends State<RenderLayout> {
  StrapiScreenSpec? spec;

  RenderLayoutState();

  @override
  initState() {
    super.initState();
    loadContent();
  }

  loadContent() {
    spec = null;
    Strapi().loadScreenLayout(widget.entry.id).then((layout) => setState(() {
      spec = layout;
    }));
  }

  @override
  Widget build(BuildContext context) {
    if (spec == null) {
      return loadingScreen();
    }

    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          topBar(context, spec?.name, () => setState(() => loadContent())),
          Expanded(
            child: Mirai.fromJson(spec?.spec, context) ?? const SizedBox(),
          ),
        ],
      ),
    );
  }
}