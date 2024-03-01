import 'package:flutter/material.dart';
import 'package:pheno_ui/interface/data/entry.dart';
import 'package:pheno_ui/pheno_ui.dart';
import 'package:pheno_ui_tester/widgets/top_bar.dart';

class RenderLayout extends StatefulWidget {
  final String initialRoute;
  final List<PhenoDataEntry> entries;

  const RenderLayout({
    super.key,
    required this.initialRoute,
    required this.entries,
  });

  @override
  State<RenderLayout> createState() => RenderLayoutState();
}


class RenderLayoutState extends State<RenderLayout> {
  final GlobalKey _key = GlobalKey<NavigatorState>();
  Navigator? navigator;

  RenderLayoutState();

  @override
  Widget build(BuildContext context) {
    navigator = Navigator(
      key: _key,
      initialRoute: widget.initialRoute,
      onGenerateRoute: (settings) {
        var type = settings.arguments ?? 'screen';

        for (var entry in widget.entries) {
          if (settings.name == entry.name) {
            FigmaScreenRenderer screen = FigmaScreenRenderer.fromFuture(
              Strapi().loadScreenLayout(entry.id)
            );

            switch (type) {
              case 'popup':
                return PageRouteBuilder(
                  opaque: false,
                  settings: settings,
                  pageBuilder: (_, __, ___) {
                    return Container(color: Colors.pinkAccent);
                  },
                );

              default:
                return PageRouteBuilder(
                  settings: settings,
                  pageBuilder: (_, __, ___) {
                    return screen;
                  },
                );
            }
          }
        }
        throw Exception('Invalid route: ${settings.name}');
      },
    );

    return Material(
      child: LayoutBuilder(
        builder: (_, constraits) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              topBar(context, widget.initialRoute, () {
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