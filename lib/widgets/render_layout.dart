import 'package:flutter/material.dart';
import 'package:pheno_ui/pheno_ui.dart';
import 'package:pheno_ui_tester/widgets/top_bar.dart';

import 'loading_screen.dart';

class RenderLayout extends StatefulWidget {
  final StrapiListEntry entry;

  const RenderLayout({
    super.key,
    required this.entry,
  });

  @override
  State<RenderLayout> createState() => RenderLayoutState();
}


class RenderLayoutState extends State<RenderLayout> {
  StrapiScreenSpec? spec;
  Widget? content;

  RenderLayoutState();

  @override
  initState() {
    super.initState();
    loadContent();
  }

  loadContent() {
    spec = null;
    content = null;
    Strapi().loadScreenLayout(widget.entry.id).then((spec) => setState(() {
      this.spec = spec;
      content = FigmaScreenRenderer.fromSpec(spec);
    }));
  }

  @override
  Widget build(BuildContext context) {
    if (content == null) {
      return loadingScreen();
    }

    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          topBar(context, spec?.name, () => setState(() => loadContent())),
          Expanded(
            child: ClipRect(
              child: content!,
            )
          ),
        ],
      ),
    );
  }
}