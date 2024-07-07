import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pheno_ui/pheno_ui.dart';
import 'package:pheno_ui_tester/widgets/login.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  Strapi().server = 'https://api.develop.mindora.dev';
  
  PhenoUi.initialize();
  if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.ensureInitialized();
  }
  runApp(const AppPhenoUI());
}


class EmulateMobileScrollBehavior extends MaterialScrollBehavior {
  const EmulateMobileScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.unknown,
  };
}

class AppPhenoUI extends StatelessWidget {
  const AppPhenoUI({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Pheno UI',
      scrollBehavior: EmulateMobileScrollBehavior(),
      home: Login(),
    );
  }
}
