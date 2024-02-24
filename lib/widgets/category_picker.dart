import 'package:flutter/material.dart';
import 'package:pheno_ui/interface/strapi.dart';
import 'package:pheno_ui_tester/widgets/picker_state.dart';
import 'package:pheno_ui_tester/widgets/screen_picker.dart';

class CategoryPicker extends PickerWidget {
  @override
  get getList => _getList;

  @override
  get builder => _builder;

  @override
  get title => 'Category';

  const CategoryPicker({ super.key });

  Widget _builder(StrapiListEntry entry, BuildContext context, _) {
    return ScreenPicker(entry: entry);
  }

  Future<List<StrapiListEntry>> _getList() {
    return Strapi().getCategoryList();
  }

  @override
  State<CategoryPicker> createState() => PickerState();
}