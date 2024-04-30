import 'package:flutter/material.dart';
import 'package:pheno_ui/interface/data/entry.dart';
import 'package:pheno_ui/interface/screens.dart';
import 'package:pheno_ui/interface/strapi.dart';
import 'package:pheno_ui_tester/widgets/picker_state.dart';
import 'package:pheno_ui_tester/widgets/render_layout.dart';

class ScreenPicker extends PickerWidget {
  @override
  get getList => _getList;

  @override
  get builder => _builder;

  @override
  get delete => _delete;

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

  Future<void> _delete(PhenoDataEntry entry) async {
    if (!Strapi().isLoggedIn) {
      throw Exception('You must be logged in to delete a screen');
    }
    await Strapi().deleteScreen(entry.id);
  }

  Future<List<PhenoDataEntry>> _getList() async {
    await FigmaScreens().refreshScreens();
    return await Strapi().getScreenList(entry.id);
  }

  @override
  State<ScreenPicker> createState() => PickerState();
}