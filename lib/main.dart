import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mirai/mirai.dart';
import 'package:phenoui_flutter/parsers/figma-safe-area.dart';
import 'package:phenoui_flutter/parsers/figma_frame.dart';
import 'package:phenoui_flutter/parsers/figma_image.dart';
import 'package:phenoui_flutter/parsers/figma_nav_button.dart';
import 'package:phenoui_flutter/parsers/figma_rectangle.dart';
import 'package:phenoui_flutter/parsers/figma_text.dart';
import 'package:phenoui_flutter/pheno/strapi.dart';
import 'package:phenoui_flutter/widgets/category_picker.dart';

Strapi kStrapi = Strapi();

void main() async {
  await Mirai.initialize(
    parsers: [
      const FigmaFrameParser(),
      const FigmaTextParser(),
      const FigmaImageParser(),
      const FigmaRectangleParser(),
      const FigmaSafeAreaParser(),
      const FigmaNavButtonParser(),
    ]
  );

  var categories = await kStrapi.getCategoryList();
  var screens = await kStrapi.getScreenList(categories[0].id);
  for (var screen in screens) {
    print('id:${screen.id} name:${screen.name}');
  }
  runApp(const PhenoUI());
}

class RouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print('didPush ${route.settings.name}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print('didPop ${previousRoute?.settings.name}');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print('didRemove ${route.settings.name}');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    print('didReplace ${newRoute?.settings.name}');
  }
}

class PhenoUI extends StatelessWidget {
  const PhenoUI({Key? key}) : super(key: key);

  Future<Map<String, dynamic>> buildWidget(BuildContext context) async {
    var jsonString = await DefaultAssetBundle.of(context).loadString('assets/hug_content.json', cache: true);
    var json = jsonDecode(jsonString) as Map<String, dynamic>;
    return json;
  }

  @override
  Widget build(BuildContext context) {
    // Navigator.of(context).
    return  MiraiApp(
      title: 'PhenoUI Demo',
      homeBuilder: (context) => const CategoryPicker(),
      navigatorObservers: [RouteObserver()],
      // homeBuilder: (context) => Container(color: Colors.red),
    );
    // return MiraiApp(
    //   title: 'PhenoUI Demo',
    //   homeBuilder: (context) => Material(
    //     child: ListView(
    //       children: <Widget>[
    //         ListTile(
    //           leading: Icon(Icons.screenshot),
    //           title: Text('Map'),
    //           onTap: () => Navigator.push(context, PageRouteBuilder(pageBuilder: (context, _, __) => Container(color: Colors.blue))),
    //         ),
    //         ListTile(
    //           leading: Icon(Icons.photo_album),
    //           title: Text('Album'),
    //         ),
    //         ListTile(
    //           leading: Icon(Icons.phone),
    //           title: Text('Phone'),
    //         ),
    //       ],
    //     ),
    //   )
    // );


    // return MiraiApp(
    //   title: 'Mirai Demo',
    //   // homeBuilder: (context) => Mirai.fromJson(data, context),
    //   homeBuilder: (context) => FutureBuilder<Map<String, dynamic>>(
    //     future: buildWidget(context),
    //     builder: (context, snapshot) {
    //       if (snapshot.hasData) {
    //         return Mirai.fromJson(snapshot.data, context) as Widget;
    //       }  else if (snapshot.hasError) {
    //         return Center(
    //           child: Column(
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             children: <Widget>[
    //               const Icon(
    //                 Icons.error_outline,
    //                 color: Colors.red,
    //                 size: 60,
    //               ),
    //               Padding(
    //                 padding: const EdgeInsets.only(top: 16),
    //                 child: Text('Error: ${snapshot.error}'),
    //               ),
    //             ],
    //           ),
    //         );
    //       }
    //       return const Center(
    //         child: Column(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: <Widget>[
    //             SizedBox(
    //               width: 60,
    //               height: 60,
    //               child: CircularProgressIndicator(),
    //             ),
    //             Padding(
    //               padding: EdgeInsets.only(top: 16),
    //               child: Text('Awaiting result...'),
    //             ),
    //           ],
    //         ),
    //       );
    //     },
    //   ),
    // );
  }
}
