import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:pheno_ui/pheno_ui.dart';
import 'package:pheno_ui_tester/widgets/category_picker.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  Strapi().server = 'https://api.develop.mindora.dev';
  await initializePhenoUi();
  if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.ensureInitialized();
  }
  runApp(const AppPhenoUI());
}

class AppPhenoUI extends StatelessWidget {
  const AppPhenoUI({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MiraiApp(
      title: 'Pheno UI',
      homeBuilder: (context) => const CategoryPicker(),
    );
  }
}
