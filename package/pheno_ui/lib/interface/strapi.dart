import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
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

  String? get user => _user;

  bool get isLoggedIn => _jwt != null;

  static final Strapi _singleton = Strapi._internal();

  factory Strapi() {
    return _singleton;
  }

  Strapi._internal() : _server = Uri.parse('http://127.0.0.1:1337');

  Future<String> login(Uri server, String user, String password) async {
    if (user.isNotEmpty && password.isNotEmpty) {
      _server = server;
      Uri url = Uri(
        scheme: _server.scheme,
        host: _server.host,
        port: _server.port,
        path: '/api/auth/local',
      );

      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'identifier': user,
          'password': password,
        })
      );

      var body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body.containsKey('jwt')) {
        _user = user;
        _jwt = body['jwt'];
        return _jwt!;
      } else if (body.containsKey('error')) {
        throw Exception(body['error']['message']);
      } else {
        throw Exception('UNKNOWN ERROR: Invalid response');
      }
    }

    throw Exception('Invalid empty user name or password');
  }

  Future<bool> loginJwt(String server, String jwt) async {
    if (JwtDecoder.isExpired(jwt)) {
      return false;
    }

    this.server = server;
    Uri url = Uri(
      scheme: _server.scheme,
      host: _server.host,
      port: _server.port,
      path: '/api/users/me',
    );

    try {
      var response = await http.get(
          url,
          headers: {
            'Authorization': 'Bearer $jwt',
          }
      );

      var body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body.containsKey('username')) {
        _user = body['username'];
        _jwt = jwt;
        return true;
      }
    } catch (e) {
      print('Error: $e');
    }

    return false;
  }

  void logout() {
    _user = null;
    _jwt = null;
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
    Uri url = Uri(
      scheme: _server.scheme,
      host: _server.host,
      port: _server.port,
      path: 'api/screens/$id',
    );

    var response = await http.get(url);
    var json = jsonDecode(response.body) as Map<String, dynamic>;
    return PhenoScreenSpec.fromJson(json['data']);
  }

  Future<void> deleteScreen(int id) async {
    Uri url = Uri(
      scheme: _server.scheme,
      host: _server.host,
      port: _server.port,
      path: 'api/screens/$id',
    );

    await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $_jwt',
      }
    );
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