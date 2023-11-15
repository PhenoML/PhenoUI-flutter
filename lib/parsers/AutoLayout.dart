import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mirai/mirai.dart';
import 'package:screen_builder_test/parsers/tools/enum.dart';

enum AutoLayoutLayout {
  horizontal,
  vertical,
  wrap,
}

enum DimensionSizing {
  fixed,
  hug,
  fill,
}

class AutoLayoutModel {
  final AutoLayoutLayout layout;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;
  final double crossSpacing;
  final DimensionSizing widthMode;
  final DimensionSizing heightMode;
  final MiraiContainer containerModel;
  final List<Map<String, dynamic>> children;

  AutoLayoutModel({
    required this.layout,
    required this.mainAxisAlignment,
    required this.crossAxisAlignment,
    required this.spacing,
    required this.crossSpacing,
    required this.widthMode,
    required this.heightMode,
    required this.containerModel,
    required this.children,
  });

  factory AutoLayoutModel.fromJson(Map<String, dynamic> json) =>
    AutoLayoutModel(
      layout: decodeEnumValue(AutoLayoutLayout.values, json['layout'], AutoLayoutLayout.horizontal),
      mainAxisAlignment: decodeEnumValue(MainAxisAlignment.values, json['mainAxisAlignment'], MainAxisAlignment.start),
      crossAxisAlignment: decodeEnumValue(CrossAxisAlignment.values, json['crossAxisAlignment'], CrossAxisAlignment.start),
      spacing: (json['spacing'] as num?)?.toDouble() ?? 0.0,
      crossSpacing: (json['crossSpacing'] as num?)?.toDouble() ?? 0.0,
      widthMode: decodeEnumValue(DimensionSizing.values, json['widthMode'], DimensionSizing.hug),
      heightMode: decodeEnumValue(DimensionSizing.values, json['heightMode'], DimensionSizing.hug),
      containerModel: MiraiContainer.fromJson(json),
      children: (json['children'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
          const []
    );
}

class AutoLayoutParser extends MiraiParser<AutoLayoutModel> {
  const AutoLayoutParser();

  @override
  AutoLayoutModel getModel(Map<String, dynamic> json) => AutoLayoutModel.fromJson(json);

  @override
  String get type => 'autoLayout';

  @override
  Widget parse(BuildContext context, AutoLayoutModel model) {
    List<Widget> children = model.children.map((json) {
      Widget child = const SizedBox();
      var miraiChild = Mirai.fromJson(json, context);
      if (miraiChild != null) {
        child = miraiChild;
        // ugh this is done this way for readability... or... is it?!
        if (
          model.layout == AutoLayoutLayout.vertical && decodeEnumValue(DimensionSizing.values, json['heightMode'], DimensionSizing.fixed) == DimensionSizing.fill
          ||
          model.layout != AutoLayoutLayout.vertical && decodeEnumValue(DimensionSizing.values, json['widthMode'], DimensionSizing.fixed) == DimensionSizing.fill
        ) {
          child = Expanded(child: child);
        }
      }
      return child;
    }).toList();
    if (model.spacing > 0.0 && model.layout != AutoLayoutLayout.wrap) {
      int toAdd = max(children.length - 1, 0);
      for (int i = 0; i < toAdd; ++i) {
        children.insert(i * 2 + 1, SizedBox(
          width: model.layout == AutoLayoutLayout.vertical ? 0 : model.spacing,
          height: model.layout == AutoLayoutLayout.vertical ? model.spacing : 0,
        ));
      }
    }

    Widget child;
    if (model.layout == AutoLayoutLayout.vertical) {
      child = Column(
        mainAxisAlignment: model.mainAxisAlignment,
        mainAxisSize: model.heightMode == DimensionSizing.hug ? MainAxisSize.min : MainAxisSize.max,
        crossAxisAlignment: model.crossAxisAlignment,
        children: children,
      );
    } else if (model.layout == AutoLayoutLayout.horizontal) {
      child = Row(
        mainAxisAlignment: model.mainAxisAlignment,
        mainAxisSize: model.widthMode == DimensionSizing.hug ? MainAxisSize.min : MainAxisSize.max,
        crossAxisAlignment: model.crossAxisAlignment,
        children: children,
      );
    } else {
      child = Wrap(
        alignment: WrapAlignment.values.byName(model.mainAxisAlignment.name),
        crossAxisAlignment: WrapCrossAlignment.values.byName(model.crossAxisAlignment.name),
        spacing: model.spacing,
        runSpacing: model.crossSpacing,
        children: children,
      );
    }

    var cmodel = model.containerModel;
    return Container(
      alignment: cmodel.alignment?.value,
      padding: cmodel.padding.parse,
      decoration: cmodel.color == null
          ? cmodel.decoration.parse
          : cmodel.decoration.parse?.copyWith(
        color: cmodel.color.toColor,
      ),
      width: model.widthMode == DimensionSizing.fill ? double.infinity : cmodel.width,
      height: model.heightMode == DimensionSizing.fill ? double.infinity : cmodel.height,
      // TODO: Add box constraints
      // constraints: BoxConstraints(
      //   minWidth: model.widthMode == DimensionSizing.fill ? double.infinity : cmodel.width ?? 0,
      //   maxWidth: model.widthMode == DimensionSizing.fixed ? cmodel.width ?? double.infinity : double.infinity,
      //   minHeight: model.heightMode == DimensionSizing.fill ? double.infinity : cmodel.height ?? 0,
      //   maxHeight: model.heightMode == DimensionSizing.fixed ? cmodel.height ?? double.infinity : double.infinity,
      // ),
      margin: cmodel.margin.parse,
      child: child,
    );
  }
}
