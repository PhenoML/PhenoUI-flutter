import 'package:flutter/material.dart';
import 'package:pheno_ui/interface/data/entry.dart';
import 'package:pheno_ui/interface/strapi.dart';
import 'package:pheno_ui_tester/widgets/picker_state.dart';
import 'package:pheno_ui_tester/widgets/render_layout.dart';

class ScreenPicker extends PickerWidget {
  @override
  get getList => _getList;

  @override
  get builder => _builder;

  @override
  get title => 'Layout';

  final PhenoDataEntry entry;

  const ScreenPicker({ super.key, required this.entry });

  Widget _builder(PhenoDataEntry entry, BuildContext context, List<PhenoDataEntry> entries) {
    return RenderLayout(
      category: this.entry.name,
      initialRoute: entry.name,
      entries: entries
    );
  }

  Future<List<PhenoDataEntry>> _getList() {
    return Strapi().getScreenList(entry.id);
  }

  @override
  State<ScreenPicker> createState() => PickerState();
}