import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pheno_ui/interface/strapi.dart';
import 'package:pheno_ui_tester/widgets/loading_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'category_picker.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  final TextEditingController _server = TextEditingController();
  final TextEditingController _user = TextEditingController();
  final TextEditingController _password = TextEditingController();
  late final SharedPreferences prefs;
  String? error;

  bool _loaded = false;

  final ButtonStyle _buttonStyle = ButtonStyle(
    minimumSize: MaterialStateProperty.all(const Size(200, 50)),
  );

  final Widget _gap = const SizedBox(height: 20);

  final TextStyle _textStyle = const TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    decoration: TextDecoration.none,
  );

  final TextStyle _errorStyle = const TextStyle(
    color: Colors.orange,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    decoration: TextDecoration.none,
  );

  final InputDecoration _inputDecoration = const InputDecoration(
    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
    border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
    contentPadding: EdgeInsets.all(10),
    isDense: true,
  );

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) async {
      this.prefs = prefs;
      _server.text = prefs.getString('strapi_server') ?? '';
      _user.text = prefs.getString('strapi_user') ?? '';
      String? jwt = prefs.getString('strapi_jwt');
      if (_server.text.isNotEmpty && jwt != null && jwt.isNotEmpty) {
        if (!await Strapi().loginJwt(_server.text, jwt)) {
          prefs.remove('strapi_jwt');
        } else {
          _user.text = Strapi().user!;
          prefs.setString('strapi_user', _user.text);
        }
      }

      setState(() {
        _loaded = true;
      });
    });
  }

  Widget _buildLogin(BuildContext context) {
    List<Widget> children = [
      Text('Server:', style: _textStyle),
      SizedBox(
        width: 300,
        // height: 100,
        child: TextField(
          decoration: _inputDecoration,
          controller: _server,
          style: _textStyle,
        ),
      ),

      _gap,

      Text('User:', style: _textStyle),
      SizedBox(
        width: 300,
        // height: 100,
        child: TextField(
          decoration: _inputDecoration,
          controller: _user,
          style: _textStyle,
        ),
      ),

      _gap,

      Text('Password:', style: _textStyle),
      SizedBox(
        width: 300,
        // height: 100,
        child: TextField(
          decoration: _inputDecoration,
          controller: _password,
          style: _textStyle,
        ),
      ),

      _gap,

      ElevatedButton(
        style: _buttonStyle,
        onPressed: () async {
          setState(() {
            _loaded = false;
          });
          try {
            String jwt = await Strapi().login(Uri.parse(_server.text), _user.text, _password.text);
            prefs.setString('strapi_server', _server.text);
            prefs.setString('strapi_user', _user.text);
            prefs.setString('strapi_jwt', jwt);
          } catch (e) {
            error = e.toString();
          }
          setState(() {
            _loaded = true;
          });
        },
        child: const Text('Login'),
      ),
    ];

    if (error != null) {
      children.add(_gap);
      children.add(Text(error!, style: _errorStyle));
    }

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }

  Widget _buildLogout(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Logged in\n\nServer:\n${Strapi().server}\n\nUser:\n${Strapi().user}\n',
            style: _textStyle,
          ),

          _gap,

          ElevatedButton(
            style: _buttonStyle,
            onPressed: () {
              setState(() {
                Strapi().logout();
                prefs.remove('strapi_jwt');
              });
            },
            child: const Text('Logout'),
          ),

          _gap,

          ElevatedButton(
            style: _buttonStyle,
            onPressed: () {
              Navigator.of(context).push(PageRouteBuilder(
                settings: const RouteSettings(name: 'category_picker'),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
                pageBuilder: (context, _, __) => const CategoryPicker(),
              ));
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return loadingScreen();
    }
    return Container(
      color: Colors.blueGrey,
      child: Strapi().isLoggedIn ? _buildLogout(context) : _buildLogin(context),
    );
  }
}