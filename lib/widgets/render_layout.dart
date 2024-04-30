import 'package:flutter/material.dart';
import 'package:pheno_ui/interface/data/entry.dart';
import 'package:pheno_ui/interface/data/strapi_provider.dart';
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

    Size? contentSize;
    double contentScale = 1.0;

    return Material(
      child: NotificationListener<ResizeNotification>(
        onNotification: (notification) {
          contentSize = notification.targetSize;
          contentScale = notification.scale;
          return true;
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                topBar(context, widget.initialRoute, () async {
                  setState(() {
                    _initialized = false;
                  });
                  await FigmaScreens().refreshScreens();
                  setState(() {
                    _initialized = true;
                  });
                }, constraints),
                Expanded(
                    child: ClipRect(
                      child: Transform.scale(
                        scale: contentScale,
                        child: OverflowBox(
                          maxWidth: double.infinity,
                          maxHeight: double.infinity,
                          child: SizedBox.fromSize(
                            size: contentSize ?? constraints.biggest,
                            child: navigator,
                          ),
                        ),
                      )
                    )
                ),
              ],
            );
          }
        ),
      ),
    );
  }
}