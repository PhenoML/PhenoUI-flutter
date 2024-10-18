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

  Strapi._internal() : _server = Uri.parse('http://127.0.0.1:8090');

  Future<String> login(Uri server, String user, String password) async {
    if (user.isNotEmpty && password.isNotEmpty) {
      _server = server;
      Uri url = Uri(
        scheme: _server.scheme,
        host: _server.host,
        port: _server.port,
        path: '/api/admins/auth-with-password',
      );

      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'identity': user,
          'password': password,
        })
      );

      var body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body.containsKey('token')) {
        _user = user;
        _jwt = body['token'];
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
      path: '/api/admins/auth-refresh',
    );

    try {
      var response = await http.post(
          url,
          headers: {
            'Authorization': 'Bearer $jwt',
          }
      );

      var body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body.containsKey('token')) {
        _user = body['admin']['email'];
        _jwt = body['token'];
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

  Future<PhenoDataEntry> _getCategory_(String name, [String collection = 'screen-categories']) async {
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
    var entry = PhenoDataEntry(data);
    return entry;
  }

  Future<List<PhenoDataEntry>> _getEntryList(String path) async {
    Uri url = Uri(
      scheme: _server.scheme,
      host: _server.host,
      port: _server.port,
      path: path,
    );

    var response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to load list');
    }

    var body = jsonDecode(response.body) as Map<String, dynamic>;
    var entries = body['items'].map((e) => PhenoDataEntry(e));
    var result = List<PhenoDataEntry>.from(entries);
    return result;
  }

  Future<List<PhenoDataEntry>> getCategoryList([String? parentId]) async {
    return _getEntryList('phui/tag/list${parentId != null ? '/$parentId' : ''}');
  }

  Future<List<PhenoDataEntry>> getScreenList(String tagId) async {
    return _getEntryList('phui/layout/list/$tagId');
  }
  
  Future<List<PhenoDataEntry>> getComponentList(String tagId) async {
    return _getEntryList('phui/widget/list/$tagId');
  }

  Future<PhenoScreenSpec> loadScreenLayout(dynamic nameOrId, String? category) async {
    if (nameOrId is String && category != null) {
      return loadScreenLayoutByName(nameOrId, category);
    } else if (nameOrId is String) {
      return loadScreenLayoutById(nameOrId);
    }
    throw Exception('Invalid name or id');
  }

  Future<PhenoScreenSpec> loadScreenLayoutByName(String name, String category) async {
    Uri url = Uri(
      scheme: _server.scheme,
      host: _server.host,
      port: _server.port,
      path: 'phui/layout/tag/$category/$name',
    );

    var response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to load list');
    }

    var json = jsonDecode(response.body) as Map<String, dynamic>;
    return PhenoScreenSpec.fromJson(json);
  }

  Future<PhenoScreenSpec> loadScreenLayoutById(String id) async {
    Uri url = Uri(
      scheme: _server.scheme,
      host: _server.host,
      port: _server.port,
      path: 'phui/layout/id/$id',
    );

    var response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to load list');
    }
    var json = jsonDecode(response.body) as Map<String, dynamic>;
    return PhenoScreenSpec.fromJson(json);
  }

  Future<void> deleteScreen(String id) async {
    throw Exception('Not implemented');
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

  Future<PhenoComponentSpec> loadComponentSpec(dynamic nameOrId, String? category) async {
    if (nameOrId is String && category != null) {
      return loadComponentSpecByName(nameOrId, category);
    } else if (nameOrId is int) {
      return loadComponentSpecById(nameOrId);
    }
    throw Exception('Invalid name or id');
  }

  Future<PhenoComponentSpec> loadComponentSpecByName(String name, String category) async {
    Uri url = Uri(
        scheme: _server.scheme,
        host: _server.host,
        port: _server.port,
        path: 'phui/widget/tag/$category/$name',
    );

    var response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to load list');
    }
    var json = jsonDecode(response.body) as Map<String, dynamic>;
    return PhenoComponentSpec.fromJson(json);
  }

  Future<PhenoComponentSpec> loadComponentSpecById(int id) async {
    Uri url = Uri(
      scheme: _server.scheme,
      host: _server.host,
      port: _server.port,
      path: 'phui/widget/id/$id',
    );

    var response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to load list');
    }
    var json = jsonDecode(response.body) as Map<String, dynamic>;
    return PhenoComponentSpec.fromJson(json);
  }
}