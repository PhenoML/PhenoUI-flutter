import 'package:flutter/material.dart';
import 'package:mirai/mirai.dart';
import 'package:json_annotation/json_annotation.dart';

Map<T, String> getEnumMap<T extends Enum>(List<T> e) => { for (var v in e) v : v.name };

final wrapAlignmentMap = getEnumMap(WrapAlignment.values);
final clipMap = getEnumMap(Clip.values);
final wrapCrossAlignmentMap = getEnumMap(WrapCrossAlignment.values);
final axisMap = getEnumMap(Axis.values);
final textDirectionMap = getEnumMap(TextDirection.values);
final verticalDirectionMap = getEnumMap(VerticalDirection.values);


class WrapModel {
  final WrapAlignment alignment;
  final Clip clipBehavior;
  final WrapCrossAlignment crossAxisAlignment;
  final Axis direction;
  final WrapAlignment runAlignment;
  final double runSpacing;
  final double spacing;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final List<Map<String, dynamic>> children;

  WrapModel({
    required this.alignment,
    required this.clipBehavior,
    required this.crossAxisAlignment,
    required this.direction,
    required this.runAlignment,
    required this.runSpacing,
    required this.spacing,
    this.textDirection,
    required this.verticalDirection,
    required this.children,
  });

  factory WrapModel.fromJson(Map<String, dynamic> json) =>
    WrapModel(
      alignment: $enumDecodeNullable(wrapAlignmentMap, json['alignment']) ?? WrapAlignment.start,
      clipBehavior: $enumDecodeNullable(clipMap, json['clipBehavior']) ?? Clip.none,
      crossAxisAlignment: $enumDecodeNullable(wrapCrossAlignmentMap, json['crossAxisAlignment']) ?? WrapCrossAlignment.start,
      direction: $enumDecodeNullable(axisMap, json['direction']) ?? Axis.horizontal,
      runAlignment: $enumDecodeNullable(wrapAlignmentMap, json['runAlignment']) ?? WrapAlignment.start,
      runSpacing: (json['runSpacing'] as num?)?.toDouble() ?? 0.0,
      spacing: (json['spacing'] as num?)?.toDouble() ?? 0.0,
      textDirection: $enumDecodeNullable(textDirectionMap, json['textDirection']),
      verticalDirection: $enumDecodeNullable(verticalDirectionMap, json['verticalDirection']) ?? VerticalDirection.down,
      children: (json['children'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
          const []
    );
}

class WrapParser extends MiraiParser<WrapModel> {
  const WrapParser();

  @override
  WrapModel getModel(Map<String, dynamic> json) => WrapModel.fromJson(json);

  @override
  String get type => 'wrap';

  @override
  Widget parse(BuildContext context, WrapModel model) {
    return Wrap(
      alignment: model.alignment,
      clipBehavior: model.clipBehavior,
      crossAxisAlignment: model.crossAxisAlignment,
      direction: model.direction,
      runAlignment: model.runAlignment,
      runSpacing: model.runSpacing,
      spacing: model.spacing,
      textDirection: model.textDirection,
      verticalDirection: model.verticalDirection,
      children: model.children.map((child) => Mirai.fromJson(child, context) ?? const SizedBox()).toList(),
    );
  }
}