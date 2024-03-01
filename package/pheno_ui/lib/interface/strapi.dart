import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pheno_ui/interface/data/component_spec.dart';
import 'package:pheno_ui/interface/data/entry.dart';
import 'package:pheno_ui/interface/data/screen_spec.dart';

class Strapi {
  Uri _server;
  String? _user;
  String? _jwt;
  
  String category = 'product';

  String get server => _server.toString();
  set server(String value) => _server = Uri.parse(value);

  static final Strapi _singleton = Strapi._internal();

  factory Strapi() {
    return _singleton;
  }

  Strapi._internal() : _server = Uri.parse('http://127.0.0.1:1337');

  void login(Uri server, String user, String password) {
    // TODO
  }

  Future<PhenoDataEntry> getCategory(String name, [String collection = 'screen-categories']) async {
    Uri url = Uri(
      scheme: _server.scheme,
      host: _server.host,
      port: _server.port,
      path: 'api/$collection',
      query: 'filters[uid][\$eq]=$name',
    );

    var response = await http.get(url);
    var body = jsonDecode(response.body) as Map<String, dynamic>;
    var data = body['data'][0];
    var entry = PhenoDataEntry(data['id'], data['attributes']['uid']);
    return entry;
  }

  Future<List<PhenoDataEntry>> getCategoryList() async {
    // TODO: make sure user is logged in
    Uri url = Uri(
      scheme: _server.scheme,
      host: _server.host,
      port: _server.port,
      path: 'api/screen-categories',
    );

    var response = await http.get(url);
    var body = jsonDecode(response.body) as Map<String, dynamic>;
    var entries = body['data'].map((e) => PhenoDataEntry(e['id'], e['attributes']['uid']));
    var result = List<PhenoDataEntry>.from(entries);
    return result;
  }

  Future<List<PhenoDataEntry>> getScreenList(int id) async {
    // TODO: make user is logged in
    Uri url = Uri(
      scheme: _server.scheme,
      host: _server.host,
      port: _server.port,
      path: 'api/screen-categories/$id',
      query: 'populate[screens][fields][0]=name',
    );

    var response = await http.get(url);
    var body = jsonDecode(response.body) as Map<String, dynamic>;
    var screens = body['data']['attributes']['screens']['data'];
    var entries = screens.map((e) => PhenoDataEntry(e['id'], e['attributes']['name']));
    var result = List<PhenoDataEntry>.from(entries);
    return result;
  }

  Future<PhenoScreenSpec> loadScreenLayout(int id) async {
    // TODO: make user is logged in
    Uri url = Uri(
      scheme: _server.scheme,
      host: _server.host,
      port: _server.port,
      path: 'api/screens/$id',
    );

    var response = await http.get(url);
    var json = jsonDecode(response.body) as Map<String, dynamic>;
    return PhenoScreenSpec.fromJson(json);
  }

  Future<PhenoComponentSpec> loadComponentSpec(String category, String name) async {
    PhenoDataEntry entry = await getCategory(category, 'figma-widget-categories');

    Uri url = Uri(
      scheme: _server.scheme,
      host: _server.host,
      port: _server.port,
      path: 'api/figma-widgets',
      queryParameters: {
        'filters[name][\$eq]': name,
        'populate': 'category',
        'filters[category][id][\$eq]': entry.id.toString(),
      }
    );

    var response = await http.get(url);
    var json = jsonDecode(response.body) as Map<String, dynamic>;
    return PhenoComponentSpec.fromJson(json['data'][0]);
  }
}