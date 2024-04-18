import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import '../interface/screens.dart';
import '../models/figma_image_model.dart';
import 'stateless_figma_node.dart';

class FigmaImage extends StatelessFigmaNode<FigmaImageModel> {
  const FigmaImage({ required super.model, super.key });

  static FigmaImage fromJson(Map<String, dynamic> json) {
    final FigmaImageModel model = FigmaImageModel.fromJson(json);
    return FigmaImage(model: model);
  }

  _loadImage(FigmaImageModel model) {
    if (model.method == FigmaImageDataMethod.embed) {
      return Image.memory(base64Decode(model.data), fit: model.fit);
    }
    return FigmaScreens().provider!.loadImage(model.data, fit: model.fit);
  }

  _loadSVG(FigmaImageModel model) {
    if (model.method == FigmaImageDataMethod.embed) {
      return SvgPicture.string(model.data, fit: model.fit);
    }
    return FigmaScreens().provider!.loadSvg(model.data, fit: model.fit);
  }

  @override
  Widget buildFigmaNode(BuildContext context) {
    Widget widget = switch (model.format) {
      FigmaImageFormat.png =>_loadImage(model),
      FigmaImageFormat.jpeg =>_loadImage(model),
      FigmaImageFormat.svg => _loadSVG(model),
      _ => throw 'ERROR: Unknown image format [${model.format.name}]',
    };

    return widget;
  }
}