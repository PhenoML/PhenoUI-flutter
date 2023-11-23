import 'dart:convert';
import 'package:http/http.dart' as http;

class StrapiListEntry {
  final int id;
  final String name;
  const StrapiListEntry(this.id, this.name);
}

class StrapiScreenSpec {
  final int id;
  final String name;
  final String slug;
  final Map<String, dynamic> spec;

  StrapiScreenSpec(this.id, this.name, this.slug, this.spec);

  factory StrapiScreenSpec.fromJson(Map<String, dynamic> json) {
    return StrapiScreenSpec(
        json['data']['id'].toInt(),
        json['data']['attributes']['name'],
        json['data']['attributes']['slug'],
        json['data']['attributes']['spec']
    );
  }
}

class Strapi {
  Uri? _server;
  String? _user;
  String? _jwt;

  static final Strapi _singleton = Strapi._internal();

  factory Strapi() {
    return _singleton;
  }

  Strapi._internal() {
    // TODO: Server shouldn't be hardcoded
    _server = Uri.parse('http://localhost:1337');
  }

  void login(Uri server, String user, String password) {
    // TODO
  }

  Future<List<StrapiListEntry>> getCategoryList() async {
    // TODO: make sure user is logged in
    Uri url = Uri(
      scheme: _server?.scheme,
      host: _server?.host,
      port: _server?.port,
      path: 'api/screen-categories',
    );

    var response = await http.get(url);
    var body = jsonDecode(response.body) as Map<String, dynamic>;
    var entries = body['data'].map((e) => StrapiListEntry(e['id'], e['attributes']['name']));
    var result = List<StrapiListEntry>.from(entries);
    return result;
  }

  Future<List<StrapiListEntry>> getScreenList(int id) async {
    // TODO: make user is logged in
    Uri url = Uri(
      scheme: _server?.scheme,
      host: _server?.host,
      port: _server?.port,
      path: 'api/screen-categories/$id',
      query: 'populate[screens][fields][0]=name',
    );

    var response = await http.get(url);
    var body = jsonDecode(response.body) as Map<String, dynamic>;
    var screens = body['data']['attributes']['screens']['data'];
    var entries = screens.map((e) => StrapiListEntry(e['id'], e['attributes']['name']));
    var result = List<StrapiListEntry>.from(entries);
    return result;
  }

  Future<StrapiScreenSpec> loadScreenLayout(int id) async {
    // TODO: make user is logged in
    Uri url = Uri(
      scheme: _server?.scheme,
      host: _server?.host,
      port: _server?.port,
      path: 'api/screens/$id',
    );

    var response = await http.get(url);
    var json = jsonDecode(response.body) as Map<String, dynamic>;
    return StrapiScreenSpec.fromJson(json);
  }
}