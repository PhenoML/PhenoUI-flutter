import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mirai/mirai.dart';
import 'package:phenoui_flutter/models/fimga_image_model.dart';
import 'package:phenoui_flutter/parsers/tools/figma_dimensions.dart';

class FigmaImageParser extends MiraiParser<FigmaImageModel> {
  const FigmaImageParser();

  @override
  FigmaImageModel getModel(Map<String, dynamic> json) =>
      FigmaImageModel.fromJson(json);

  @override
  String get type => 'figma-image';

  @override
  Widget parse(BuildContext context, FigmaImageModel model) {
    Widget widget = switch (model.format) {
      FigmaImageFormat.png => Image.memory(base64Decode(model.data), fit: model.fit),
      FigmaImageFormat.svg => SvgPicture.string(model.data, fit: model.fit),
      _ => throw 'ERROR: Unknown image format [${model.format.name}]',
    };

    return dimensionWrapWidget(widget, model.dimensions, model.parentLayout);
  }
}