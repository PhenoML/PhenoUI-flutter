import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';


import '../models/figma_node_model.dart';
import 'stateful_figma_node.dart';

class FigmaWebView extends StatefulFigmaNode<FigmaNodeModel> {
  const FigmaWebView({required super.model, super.key});

  static FigmaWebView fromJson(Map<String, dynamic> json) {
    final FigmaNodeModel model = FigmaNodeModel.fromJson(json);
    return FigmaWebView(model: model);
  }

  @override
  StatefulFigmaNodeState createState() => FigmaWebViewState();
}

class FigmaWebViewState extends StatefulFigmaNodeState<FigmaWebView> {
  WebViewController? _controller;

  @override
  void initState() {
    super.initState();

    if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
      _controller = WebViewController();
      if (!kIsWeb) {
        _controller!
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x00000000));
      }
      _controller!.loadRequest(Uri.parse(widget.model.userData.get('URL')));
    }
  }

  @override
  Widget buildFigmaNode(BuildContext context) {
    if (_controller != null) {
      return WebViewWidget(controller: _controller!);
    }

    return Container(
      color: const Color.fromRGBO(245, 245, 245, 1.0),
      child: const Center(
        child: Text('WebView is not supported on this platform'),
      )
    );
  }
}
