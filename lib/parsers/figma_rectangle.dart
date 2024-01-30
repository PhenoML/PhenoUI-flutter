import 'package:flutter/material.dart';
import 'package:mirai/mirai.dart';

class FigmaRectangleModel {

}

class FigmaRectangleParser extends MiraiParser<FigmaRectangleModel> {
  const FigmaRectangleParser();

  @override
  FigmaRectangleModel getModel(Map<String, dynamic> json) => FigmaRectangleModel();

  @override
  String get type => 'figma_rectangle';

  @override
  Widget parse(BuildContext context, FigmaRectangleModel model) {
    return Container();
  }
}