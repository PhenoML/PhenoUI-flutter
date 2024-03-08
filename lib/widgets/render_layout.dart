import 'package:flutter/material.dart';
import 'package:pheno_ui/interface/data/entry.dart';
import 'package:pheno_ui/interface/data/strapi_provider.dart';
import 'package:pheno_ui/interface/screens.dart';
import 'package:pheno_ui/pheno_ui.dart';
import 'package:pheno_ui_tester/widgets/top_bar.dart';

class RenderLayout extends StatefulWidget {
  final String category;
  final String initialRoute;
  final List<PhenoDataEntry> entries;

  const RenderLayout({
    super.key,
    required this.category,
    required this.initialRoute,
    required this.entries,
  });

  @override
  State<RenderLayout> createState() => RenderLayoutState();
}


class RenderLayoutState extends State<RenderLayout> {
  final GlobalKey _key = GlobalKey<NavigatorState>();
  bool _initialized = false;
  Navigator? navigator;

  RenderLayoutState();

  @override
  void initState() {
    super.initState();
    var dataProvider = StrapiDataProvider(sourceId: Strapi().server, category: widget.category);
    FigmaScreens().setProvider(dataProvider).then((_) => setState(() {
      _initialized = true;
    }));
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.blueGrey,
          strokeWidth: 11.0,
          strokeCap: StrokeCap.round,
        ),
      );
    }

    navigator = Navigator(
      key: _key,
      initialRoute: widget.initialRoute,
      onGenerateRoute: (settings) => FigmaScreens().generateRoute(settings),
    );

    return Material(
      child: LayoutBuilder(
        builder: (_, constraits) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              topBar(context, widget.initialRoute, () {
                FigmaScreens().clearCache();
                NavigatorState state = _key.currentState! as NavigatorState;
                state.pushNamedAndRemoveUntil(widget.initialRoute, (route) => false);
              }, constraits),
              Expanded(
                  child: ClipRect(
                    child: navigator!,
                  )
              ),
            ],
          );
        }
      ),
    );
  }
}