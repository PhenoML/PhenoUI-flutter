import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirai/mirai.dart';
import 'package:pheno_ui/models/figma_simple_style_model.dart';
import 'package:pheno_ui/parsers/tools/figma_dimensions.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../widgets/figma_node.dart';

class FigmaWebViewParser extends MiraiParser<FigmaSimpleStyleModel> {
  const FigmaWebViewParser();

  @override
  FigmaSimpleStyleModel getModel(Map<String, dynamic> json) => FigmaSimpleStyleModel.fromJson(json);

  @override
  String get type => 'figma-web-view';

  @override
  Widget parse(BuildContext context, FigmaSimpleStyleModel model) {
    Widget widget;

    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      var controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..loadRequest(Uri.parse(model.userData.get('URL')));
      widget = WebViewWidget(controller: controller);
    } else {
      widget = Container(
        color: const Color.fromRGBO(245, 245, 245, 1.0),
        child: const Center(
          child: Text('WebView is not supported on this platform'),
        )
      );
    }

    widget = FigmaNode.withContext(context,
      model: model,
      child: widget,
    );

    return dimensionWrapWidget(widget, model.dimensions!, model.parentLayout);
  }
}