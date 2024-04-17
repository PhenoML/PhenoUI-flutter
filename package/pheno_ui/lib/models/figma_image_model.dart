import 'package:flutter/material.dart';
import '../tools/figma_enum.dart';
import 'figma_node_model.dart';

enum FigmaImageFormat with FigmaEnum {
  png,
  jpeg,
  svg,
  unknown,
  ;
  @override
  get figmaName => _figmaName;
  final String? _figmaName;
  const FigmaImageFormat([this._figmaName]);
}

enum FigmaImageDataMethod with FigmaEnum {
  upload,
  link,
  embed,
  ;
  @override
  get figmaName => _figmaName;
  final String? _figmaName;
  const FigmaImageDataMethod([this._figmaName]);
}

class FigmaImageModel extends FigmaNodeModel {
  final FigmaImageFormat format;
  final double opacity;
  final BoxFit fit;
  final String data;
  final FigmaImageDataMethod method;

  FigmaImageModel.fromJson(Map<String, dynamic> json):
      format = FigmaImageFormat.values.byNameDefault(json['format'], FigmaImageFormat.unknown),
      opacity = json['opacity'].toDouble(),
      fit = BoxFit.values.byNameDefault(json['__userData']['scaling'], BoxFit.none),
      data = json['data'],
      method = FigmaImageDataMethod.values.byNameDefault(json['__userData']['method'] ?? json['uploadMethod'], FigmaImageDataMethod.embed),
      super.fromJson(json);
}