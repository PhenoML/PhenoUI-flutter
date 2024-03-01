import 'package:pheno_ui/interface/data/provider.dart';
import 'package:pheno_ui/interface/data/screen_spec.dart';

import '../strapi.dart';
import 'entry.dart';

class StrapiDataProvider extends PhenoDataProvider {
  const StrapiDataProvider._({
    required String sourceId,
    required String category,
  }) : super(sourceId: sourceId, category: category);

  factory StrapiDataProvider({
    String? sourceId,
    String category = 'main',
  }) {
    if (sourceId == null) {
      sourceId = Strapi().server;
    } else {
      Strapi().server = sourceId;
    }

    return StrapiDataProvider._(
      sourceId: sourceId,
      category: category,
    );
  }

  @override
  Future<List<PhenoDataEntry>> getScreenList() async {
    var category = await Strapi().getCategory(this.category);
    return await Strapi().getScreenList(category.id);
  }

  @override
  Future<PhenoScreenSpec> loadScreenLayout(int id) async {
    return await Strapi().loadScreenLayout(id);
  }
}