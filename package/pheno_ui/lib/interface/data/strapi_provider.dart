import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pheno_ui/interface/data/provider.dart';
import 'package:pheno_ui/interface/data/screen_spec.dart';

import '../strapi.dart';
import 'component_spec.dart';
import 'entry.dart';

class StrapiDataProvider extends PhenoDataProvider {
  StrapiDataProvider._({
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

    Strapi().category = category;

    return StrapiDataProvider._(
      sourceId: sourceId,
      category: category,
    );
  }

  @override
  Future<List<PhenoDataEntry>> doGetScreenList() async {
    var category = await Strapi().getCategory(this.category);
    return await Strapi().getScreenList(category.id);
  }

  @override
  Future<PhenoScreenSpec> doLoadScreenLayout(int id) async {
    return await Strapi().loadScreenLayout(id);
  }

  @override
  Future<PhenoComponentSpec> doLoadComponentSpec(String name) async {
    return await Strapi().loadComponentSpec(category, name);
  }

  @override
  Image loadPng(String path, { required BoxFit fit }) {
    return Image.network(path, fit: fit);
  }

  @override
  SvgPicture loadSvg(String path, { required BoxFit fit }) {
    return SvgPicture.network(path, fit: fit);
  }
}