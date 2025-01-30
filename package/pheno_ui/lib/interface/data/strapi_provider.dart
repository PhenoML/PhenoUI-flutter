import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:pheno_ui/interface/data/provider.dart';
import 'package:pheno_ui/interface/data/screen_spec.dart';
import 'package:http/http.dart' as http;

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
    return await Strapi().getScreenList(category);
  }

  @override
  Future<PhenoScreenSpec> doLoadScreenLayout(String id) async {
    return await Strapi().loadScreenLayoutById(id);
  }

  @override
  Future<PhenoComponentSpec> doLoadComponentSpec(String name) async {
    return await Strapi().loadComponentSpecByName(name, category);
  }

  @override
  Image loadImage(String id, { required BoxFit fit }) {
    Uri server = Uri.parse(Strapi().server);
    Uri url = Uri(
      scheme: server.scheme,
      host: server.host,
      port: server.port,
      path: 'phui/media/file/id/$id',
    );
    return Image.network(url.toString(), fit: fit);
  }

  @override
  SvgPicture loadSvg(String id, { required BoxFit fit }) {
    Uri server = Uri.parse(Strapi().server);
    Uri url = Uri(
      scheme: server.scheme,
      host: server.host,
      port: server.port,
      path: 'phui/media/file/id/$id',
    );
    return SvgPicture.network(url.toString(), fit: fit);
  }

  @override
  Future<LottieComposition> doLoadAnimation(String id) async {
    Uri server = Uri.parse(Strapi().server);
    Uri url = Uri(
      scheme: server.scheme,
      host: server.host,
      port: server.port,
      path: 'phui/media/file/id/$id',
    );
    return NetworkLottie(url.toString()).load();
  }
}