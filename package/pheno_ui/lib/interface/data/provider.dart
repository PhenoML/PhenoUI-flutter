
import 'package:pheno_ui/interface/data/screen_spec.dart';

import 'component_spec.dart';
import 'entry.dart';

abstract class PhenoDataProvider {
  final String sourceId;
  final String category;

  const PhenoDataProvider({
    required this.sourceId,
    required this.category,
  });

  Future<List<PhenoDataEntry>> getScreenList();
  Future<PhenoScreenSpec> loadScreenLayout(int id);
  Future<PhenoComponentSpec> loadComponentSpec(String name);
}