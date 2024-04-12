import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mirai/mirai.dart';
import 'package:pheno_ui/widgets/figma_node_old.dart';
import '../interface/screens.dart';
import './tools/figma_dimensions.dart';

import '../models/fimga_image_model.dart';

class FigmaImageParser extends MiraiParser<FigmaImageModel> {
  const FigmaImageParser();

  @override
  FigmaImageModel getModel(Map<String, dynamic> json) =>
      FigmaImageModel.fromJson(json);

  @override
  String get type => 'figma-image';

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
  Widget parse(BuildContext context, FigmaImageModel model) {
    Widget widget = switch (model.format) {
      FigmaImageFormat.png =>_loadImage(model),
      FigmaImageFormat.jpeg =>_loadImage(model),
      FigmaImageFormat.svg => _loadSVG(model),
      _ => throw 'ERROR: Unknown image format [${model.format.name}]',
    };

    widget = FigmaNodeOld.withContext(context,
      model: model,
      child: widget,
    );

    return dimensionWrapWidget(widget, model.dimensions!, model.parentLayout);
  }
}