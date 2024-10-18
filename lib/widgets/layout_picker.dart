import 'package:flutter/material.dart';
import 'package:pheno_ui/interface/strapi.dart';
import 'package:pheno_ui_tester/widgets/picker_state.dart';

import 'render_layout.dart';

class LayoutPicker extends PickerWidget {
  @override
  get getList => _getList;

  @override
  get builder => _builder;

  @override
  get title => entry != null ? entry!.path : 'Category';

  final PickerEntry? entry;

  const LayoutPicker({ super.key, this.entry });

  Widget _builder(PickerEntry entry, BuildContext context, _) {
    if (entry.type == PickerEntryType.tag) {
      return LayoutPicker(entry: entry);
    }
    return RenderLayout(
        tagId: this.entry!.id,
        initialRoute: entry.name,
    );
  }

  Future<List<PickerEntry>> _getList() async {
    List<PickerEntry> entries = [];
    final tagList = await Strapi().getCategoryList(entry?.id);
    for (var tagEntry in tagList) {
      entries.add(PickerEntry(tagEntry, PickerEntryType.tag));
    }

    if (entry != null) {
      final layoutList = await Strapi().getScreenList(entry!.id);
      for (var layoutEntry in layoutList) {
        entries.add(PickerEntry(layoutEntry, PickerEntryType.layout));
      }
    }

    return entries;
  }

  @override
  State<LayoutPicker> createState() => PickerState();
}