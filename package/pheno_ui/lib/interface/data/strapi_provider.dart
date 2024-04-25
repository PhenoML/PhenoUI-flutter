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
  Image loadImage(String path, { required BoxFit fit }) {
    // make sure that the path is retrieving the image from the server
    // configured in the strapi class
    Uri uri = Uri.parse(path);
    Uri strapiServer = Uri.parse(Strapi().server);
    Uri newUri = Uri(
      scheme: strapiServer.scheme,
      host: strapiServer.host,
      port: strapiServer.port,
      path: uri.path,
    );
    return Image.network(newUri.toString(), fit: fit);
  }

  @override
  SvgPicture loadSvg(String path, { required BoxFit fit }) {
    // make sure that the path is retrieving the image from the server
    // configured in the strapi class
    Uri uri = Uri.parse(path);
    Uri strapiServer = Uri.parse(Strapi().server);
    Uri newUri = Uri(
      scheme: strapiServer.scheme,
      host: strapiServer.host,
      port: strapiServer.port,
      path: uri.path,
    );
    return SvgPicture.network(newUri.toString(), fit: fit);
  }

  @override
  Future<LottieComposition> doLoadAnimation(String path) async {
    // make sure that the path is retrieving the image from the server
    // configured in the strapi class
    Uri uri = Uri.parse(path);
    Uri strapiServer = Uri.parse(Strapi().server);
    Uri newUri = Uri(
      scheme: strapiServer.scheme,
      host: strapiServer.host,
      port: strapiServer.port,
      path: uri.path,
    );
    return NetworkLottie(newUri.toString()).load();
  }
}