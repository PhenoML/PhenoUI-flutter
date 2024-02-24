import 'package:flutter/material.dart';
import 'package:pheno_ui/interface/strapi.dart';
import 'package:pheno_ui_tester/widgets/top_bar.dart';

import 'loading_screen.dart';

abstract class PickerWidget extends StatefulWidget {
  const PickerWidget({super.key});
  Future<List<StrapiListEntry>> Function() get getList;
  Widget Function(StrapiListEntry, BuildContext, List<StrapiListEntry>) get builder;
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
          pageBuilder: (context, _, __) => widget.builder(e, context, entries!),
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