import 'package:flutter/material.dart';
import 'package:pheno_ui/interface/data/entry.dart';
import 'package:pheno_ui/interface/strapi.dart';
import 'package:pheno_ui_tester/widgets/top_bar.dart';

import 'loading_screen.dart';

enum PickerEntryType {
  tag,
  layout,
}

class PickerEntry {
  final PhenoDataEntry pde;
  final PickerEntryType type;

  const PickerEntry(this.pde, this.type);

  String get id => pde.id;
  String get uid => pde.uid;
  String get name => pde.name;
  String get path => pde.data['path'];
}

abstract class PickerWidget extends StatefulWidget {
  const PickerWidget({super.key});
  Future<List<PickerEntry>> Function() get getList;
  Widget Function(PickerEntry, BuildContext, List<PickerEntry>) get builder;
  Future<void> Function(PickerEntry)? get delete => null;
  String get title;
}

class PickerState<T extends PickerWidget> extends State<T> {
  List<PickerEntry>? entries;
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
      leading: Icon(
        e.type == PickerEntryType.tag ? Icons.folder_outlined : Icons.file_open_outlined,
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