import 'package:flutter/material.dart';
import 'package:pheno_ui/interface/data/entry.dart';
import 'package:pheno_ui/interface/strapi.dart';
import 'package:pheno_ui_tester/widgets/top_bar.dart';

import 'loading_screen.dart';

abstract class PickerWidget extends StatefulWidget {
  const PickerWidget({super.key});
  Future<List<PhenoDataEntry>> Function() get getList;
  Widget Function(PhenoDataEntry, BuildContext, List<PhenoDataEntry>) get builder;
  Future<void> Function(PhenoDataEntry)? get delete => null;
  String get title;
}

class PickerState<T extends PickerWidget> extends State<T> {
  List<PhenoDataEntry>? entries;
  bool _loading = false;

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
    if (entries == null || _loading) {
      return loadingScreen();
    }

    List<Widget> children = (entries as List).map((e) => ListTile(
      leading: const Icon(
        Icons.screenshot,
        size: 20,
      ),
      trailing: widget.delete == null? null :IconButton(
        onPressed: () async {
          setState(() => _loading = true);
          await widget.delete!(e);
          _loading = false;
          loadEntries();
        },
        icon: const Icon(
          Icons.delete,
          size: 16,
        ),
      ),
      title: Text(e.name),
      titleTextStyle: const TextStyle(
        color: Colors.black,
        fontSize: 14,
      ),
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