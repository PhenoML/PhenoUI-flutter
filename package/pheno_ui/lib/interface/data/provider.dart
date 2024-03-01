
import 'package:pheno_ui/interface/data/screen_spec.dart';

import 'entry.dart';

abstract class PhenoDataProvider {
  final String sourceId;
  final String category;

  PhenoDataProvider({
    required this.sourceId,
    required this.category,
  });

  Future<List<PhenoDataEntry>> getScreenList();
  Future<PhenoScreenSpec> loadScreenLayout(int id);
}