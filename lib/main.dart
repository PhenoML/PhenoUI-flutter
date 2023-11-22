import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mirai/mirai.dart';
import 'package:phenoui_flutter/parsers/auto_layout.dart';
import 'package:phenoui_flutter/parsers/figma_frame.dart';
import 'package:phenoui_flutter/parsers/wrap.dart';

void main() async {
  await Mirai.initialize(
    parsers: [
      const WrapParser(),
      const AutoLayoutParser(),
      const FigmaFrameParser(),
    ]
  );

  runApp(const PhenoUI());
}

class PhenoUI extends StatelessWidget {
  const PhenoUI({Key? key}) : super(key: key);

  Future<Map<String, dynamic>> buildWidget(BuildContext context) async {
    var jsonString = await DefaultAssetBundle.of(context).loadString('assets/aligned_column.json', cache: true);
    var json = jsonDecode(jsonString) as Map<String, dynamic>;
    return json;
  }

  @override
  Widget build(BuildContext context) {
    return MiraiApp(
      title: 'Mirai Demo',
      // homeBuilder: (context) => Mirai.fromJson(data, context),
      homeBuilder: (context) => FutureBuilder<Map<String, dynamic>>(
        future: buildWidget(context),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Mirai.fromJson(snapshot.data, context) as Widget;
          }  else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text('Error: ${snapshot.error}'),
                  ),
                ],
              ),
            );
          }
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text('Awaiting result...'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
