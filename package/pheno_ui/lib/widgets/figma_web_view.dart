import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../models/figma_node_model.dart';
import 'stateless_figma_node.dart';

class FigmaWebView extends StatelessFigmaNode<FigmaNodeModel> {
  const FigmaWebView({required super.model, super.key});

  static FigmaWebView fromJson(Map<String, dynamic> json) {
    final FigmaNodeModel model = FigmaNodeModel.fromJson(json);
    return FigmaWebView(model: model);
  }

  @override
  Widget buildFigmaNode(BuildContext context) {
    Widget widget;

    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      var controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..loadRequest(Uri.parse(model.userData.get('URL')));
      return WebViewWidget(controller: controller);
    }

    return Container(
      color: const Color.fromRGBO(245, 245, 245, 1.0),
      child: const Center(
        child: Text('WebView is not supported on this platform'),
      )
    );
  }
}
