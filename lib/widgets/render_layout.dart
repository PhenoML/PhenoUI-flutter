import 'package:flutter/material.dart';
import 'package:pheno_ui/interface/data/entry.dart';
import 'package:pheno_ui/interface/data/strapi_provider.dart';
import 'package:pheno_ui/pheno_ui.dart';
import 'package:pheno_ui_tester/widgets/picker_state.dart';
import 'package:pheno_ui_tester/widgets/top_bar.dart';

class RenderLayout extends StatefulWidget {
  final String tagId;
  final String initialRoute;

  const RenderLayout({
    super.key,
    required this.tagId,
    required this.initialRoute,
  });

  @override
  State<RenderLayout> createState() => RenderLayoutState();
}

class RenderLayoutState extends State<RenderLayout> {
  final GlobalKey _key = GlobalKey<NavigatorState>();
  bool _initialized = false;
  Navigator? navigator;
  Size? contentSize;
  double contentScale = 1.0;

  RenderLayoutState();

  @override
  void initState() {
    super.initState();
    var dataProvider = StrapiDataProvider(sourceId: Strapi().server, category: widget.tagId);
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
                      child: Flow(
                        delegate: _FlowDelegate(this),
                        children: [
                          SizedBox.fromSize(
                            size: contentSize ?? constraints.biggest,
                            child: navigator,
                          )
                        ],
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

class _FlowDelegate extends FlowDelegate {
  final RenderLayoutState state;
  _FlowDelegate(this.state);

  @override
  void paintChildren(FlowPaintingContext context) {
    context.paintChild(0, transform: Matrix4.identity()..scale(state.contentScale));
  }

  @override
  bool shouldRepaint(covariant FlowDelegate oldDelegate) {
    return oldDelegate != this;
  }

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    return BoxConstraints.tight(state.contentSize ?? constraints.biggest);
  }

}
