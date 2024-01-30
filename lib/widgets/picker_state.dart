import 'package:flutter/material.dart';
import 'package:phenoui_flutter/pheno/strapi.dart';
import 'package:phenoui_flutter/widgets/loading_screen.dart';
import 'package:phenoui_flutter/widgets/top_bar.dart';

abstract class PickerWidget extends StatefulWidget {
  const PickerWidget({super.key});
  Future<List<StrapiListEntry>> Function() get getList;
  Widget Function(StrapiListEntry, BuildContext) get builder;
  String get title;
}

class PickerState<T extends PickerWidget> extends State<T> {
  List<StrapiListEntry>? entries;

  PickerState();

  @override
  initState() {
    super.initState();
    loadEntries();
  }

  loadEntries() {
    entries = null;
    widget.getList().then((list) => setState(() {
      entries = list;
    }));
  }

  @override
  Widget build(BuildContext context) {
    if (entries == null) {
      return loadingScreen();
    }

    List<Widget> children = (entries as List).map((e) => ListTile(
      leading: const Icon(Icons.screenshot),
      title: Text(e.name),
      onTap: () => Navigator.push(context, PageRouteBuilder(
          settings: RouteSettings(name: '${ModalRoute.of(context)!.settings.name}${e.name}/'),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          pageBuilder: (context, _, __) => widget.builder(e, context),
      )),
    )).toList();

    return Material(
      child: Column(
        children: [
          topBar(context, widget.title, () => setState(() => loadEntries())),
          Expanded(
            child: ListView(
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}