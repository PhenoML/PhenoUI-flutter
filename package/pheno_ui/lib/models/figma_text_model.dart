import 'dart:ui';

import '../parsers/tools/figma_enum.dart';
import 'figma_node_model.dart';

/// The horizontal alignment of the text with respect to the textbox. Setting
/// this property requires the font the be loaded.
enum FigmaTextAlignHorizontal with FigmaEnum {
  left('LEFT'),
  center('CENTER'),
  right('RIGHT'),
  justify('JUSTIFIED'),
  ;
  @override
  get figmaName => _figmaName;
  final String? _figmaName;
  const FigmaTextAlignHorizontal([this._figmaName]);
}

/// The vertical alignment of the text with respect to the textbox. Setting this
/// property requires the font the be loaded.
enum FigmaTextAlignVertical with FigmaEnum {
  top('TOP'),
  center('CENTER'),
  bottom('BOTTOM'),
  ;
  @override
  get figmaName => _figmaName;
  final String? _figmaName;
  const FigmaTextAlignVertical([this._figmaName]);
}


/// The behavior of how the size of the text box adjusts to fit the characters.
/// Setting this property requires the font the be loaded.
///
/// - "NONE":   The size of the textbox is fixed and is independent of its
///             content.
/// - "HEIGHT": The width of the textbox is fixed. Characters wrap to fit in the
///             textbox. The height of the textbox automatically adjusts to fit
///             its content.
/// - "WIDTH_AND_HEIGHT": Both the width and height of the textbox automatically
///             adjusts to fit its content. Characters do not wrap.
/// - [DEPRECATED] "TRUNCATE": Like "NONE", but text that overflows the bounds
///             of the text node will be truncated with an ellipsis. This value
///             will be removed in the future - prefer reading from
///             textTruncation instead.
enum FigmaTextAutoResize with FigmaEnum {
  none('NONE'),
  widthAndHeight('WIDTH_AND_HEIGHT'),
  height('HEIGHT'),
  truncate('TRUNCATE'),
  ;
  @override
  get figmaName => _figmaName;
  final String? _figmaName;
  const FigmaTextAutoResize([this._figmaName]);
}

/// Whether this text node will truncate with an ellipsis when the text node
/// size is smaller than the text inside.
///
/// When textAutoResize is set to "NONE", the text will truncate when the fixed
/// size is smaller than the text insdie. When it is "HEIGHT" or
/// WIDTH_AND_HEIGHT", truncation will only occur if used in conjunction with
/// maxHeight or maxLines.
enum FigmaTextTruncation with FigmaEnum {
  disabled('DISABLED'),
  ending('ENDING'),
  ;
  @override
  get figmaName => _figmaName;
  final String? _figmaName;
  const FigmaTextTruncation([this._figmaName]);
}

/// - "NONE": the text is shown without decorations.
/// - "UNDERLINE": the text has a horizontal line underneath it.
/// - "STRIKETHROUGH": the text has a horizontal line crossing it in the middle.
enum FigmaTextDecoration with FigmaEnum {
  none('NONE'),
  underline('UNDERLINE'),
  strikethrough('STRIKETHROUGH'),
  ;
  @override
  get figmaName => _figmaName;
  final String? _figmaName;
  const FigmaTextDecoration([this._figmaName]);
}

/// - "ORIGINAL": show the text as defined, no overrides.
/// - "UPPER":  all characters are in upper case.
/// - "LOWER":  all characters are in lower case.
/// - "TITLE":  the first character of each word is upper case and all other
///             characters are in lower case.
/// - "SMALL_CAPS": all characters are in small upper case.
/// - "SMALL_CAPS_FORCED": the first character of each word is upper case and
///             all other characters are in small upper case.
enum FigmaTextCase with FigmaEnum {
  original('ORIGINAL'),
  upper('UPPER'),
  lower('LOWER'),
  title('TITLE'),
  smallCaps('SMALL_CAPS'),
  smallCapsForced('SMALL_CAPS_FORCED'),
  ;
  @override
  get figmaName => _figmaName;
  final String? _figmaName;
  const FigmaTextCase([this._figmaName]);
}

/// - "ORDERED":  if the text range has been set to be part of an ordered list
///               (ie: list with numerical counter).
/// - "UNORDERED": if the text range has been set to be part of an unordered
///               list (ie: bulleted list).
/// - "NONE": if the text range is plain text and is not part of any list
enum FigmaTextListOptionsType with FigmaEnum {
  ordered('ORDERED'),
  unordered('UNORDERED'),
  none('NONE'),
  ;
  @override
  get figmaName => _figmaName;
  final String? _figmaName;
  const FigmaTextListOptionsType([this._figmaName]);
}

/// "URL":  value is a hyperlink URL. If the URL points to a valid node in the
///         current document, the HyperlinkTarget is automatically converted to
///         type "NODE".
/// "NODE": value is the id of a node in the current document. Note that the
///         node cannot be a sublayer of an instance.
enum FigmaTextHyperlinkType with FigmaEnum {
  url('URL'),
  node('NODE'),
  ;
  @override
  get figmaName => _figmaName;
  final String? _figmaName;
  const FigmaTextHyperlinkType([this._figmaName]);
}

enum FigmaTextUnit with FigmaEnum {
  auto('AUTO'),
  pixels('PIXELS'),
  percent('PERCENT'),
  ;
  @override
  get figmaName => _figmaName;
  final String? _figmaName;
  const FigmaTextUnit([this._figmaName]);
}

enum FigmaFontStyle with FigmaEnum {
  normal('Regular'),
  italic('Italic'),
  ;
  @override
  get figmaName => _figmaName;
  final String? _figmaName;
  const FigmaFontStyle([this._figmaName]);
}

/// An object representing a number with a unit. This is similar to how you can
/// set either 100% or 100px in a lot of CSS properties. It can also be set to
/// AUTO.
class FigmaTextValue {
  final FigmaTextUnit unit;
  final double? value;
  FigmaTextValue(this.unit, this.value);
  factory FigmaTextValue.fromJson(Map<String, dynamic> json) =>
      FigmaTextValue(
          FigmaTextUnit.values.byNameDefault(json['unit'], FigmaTextUnit.auto),
          json['value']?.toDouble()
      );
}

/// Describes a font used by a text node. For example, the default font is
/// { family: "Inter", style: "Regular" }.
class FigmaFontName {
  final String family;
  final FigmaFontStyle style;
  FigmaFontName(this.family, this.style);
  factory FigmaFontName.fromJson(Map<String, dynamic> json) =>
      FigmaFontName(
          json['family'],
          FigmaFontStyle.values.byNameDefault(json['style'], FigmaFontStyle.normal),
      );
}

/// An object describing list settings for a range of text. The possible values
/// for type are:
///
/// - "ORDERED":  if the text range has been set to be part of an ordered list
///               (ie: list with numerical counter).
/// - "UNORDERED": if the text range has been set to be part of an unordered
///               list (ie: bulleted list).
/// - "NONE": if the text range is plain text and is not part of any list
class FigmaTextListOptionsModel {
  final FigmaTextListOptionsType type;
  FigmaTextListOptionsModel(this.type);
  factory FigmaTextListOptionsModel.fromJson(Map<String, dynamic> json) =>
      FigmaTextListOptionsModel(
        FigmaTextListOptionsType.values.byNameDefault(json['type'], FigmaTextListOptionsType.none)
      );
}

/// An object representing hyperlink target. The possible values for type are:
///
/// - "URL":  value is a hyperlink URL. If the URL points to a valid node in the
///           current document, the HyperlinkTarget is automatically converted
///           to type "NODE".
/// - "NODE": value is the id of a node in the current document. Note that the
///           node cannot be a sublayer of an instance.
class FigmaTextHyperlinkTarget {
  final FigmaTextHyperlinkType type;
  final String value;
  FigmaTextHyperlinkTarget(this.type, this.value);
  factory FigmaTextHyperlinkTarget.fromJson(Map<String, dynamic> json) =>
      FigmaTextHyperlinkTarget(
        FigmaTextHyperlinkType.values.byNameDefault(json['type'], FigmaTextHyperlinkType.url),
        json['value'],
      );
}

class FigmaTextSegmentModel {
  final String characters;
  final int start;
  final int end;
  final double size;
  final FigmaFontName name;
  final FontWeight weight;
  final FigmaTextDecoration decoration;
  final FigmaTextCase textCase;
  final FigmaTextValue lineHeight;
  final FigmaTextValue letterSpacing;
  final Color color;
  final FigmaTextListOptionsModel listOptions;
  final int indentation;
  final FigmaTextHyperlinkTarget? hyperlink;

  FigmaTextSegmentModel(
      this.characters,
      this.start,
      this.end,
      this.size,
      this.name,
      this.weight,
      this.decoration,
      this.textCase,
      this.lineHeight,
      this.letterSpacing,
      this.color,
      this.listOptions,
      this.indentation,
      this.hyperlink,
  );

  factory FigmaTextSegmentModel.copy(FigmaTextSegmentModel model, {
    String? characters,
    int? start,
    int? end,
    double? size,
    FigmaFontName? name,
    FontWeight? weight,
    FigmaTextDecoration? decoration,
    FigmaTextCase? textCase,
    FigmaTextValue? lineHeight,
    FigmaTextValue? letterSpacing,
    Color? color,
    FigmaTextListOptionsModel? listOptions,
    int? indentation,
    FigmaTextHyperlinkTarget? hyperlink,
  }) {
    return FigmaTextSegmentModel(
      characters ?? model.characters,
      start ?? model.start,
      end ?? model.end,
      size ?? model.size,
      name ?? model.name,
      weight ?? model.weight,
      decoration ?? model.decoration,
      textCase ?? model.textCase,
      lineHeight ?? model.lineHeight,
      letterSpacing ?? model.letterSpacing,
      color ?? model.color,
      listOptions ?? model.listOptions,
      indentation ?? model.indentation,
      hyperlink ?? model.hyperlink,
    );
  }

  factory FigmaTextSegmentModel.fromJson(Map<String, dynamic> json) {
    FontWeight weight = switch (json['fontWeight'].toInt()) {
      > 0 && <= 100 => FontWeight.w100,
      > 100 && <= 200 => FontWeight.w200,
      > 200 && <= 300 => FontWeight.w300,
      > 300 && <= 400 => FontWeight.w400,
      > 400 && <= 500 => FontWeight.w500,
      > 500 && <= 600 => FontWeight.w600,
      > 600 && <= 700 => FontWeight.w700,
      > 700 && <= 800 => FontWeight.w800,
      > 800 && <= 900 => FontWeight.w900,
      _ => FontWeight.normal
    };
    Color color = Color.fromRGBO(
        (json['fills'][0]['color']['r'] * 255.0).round(),
        (json['fills'][0]['color']['g'] * 255.0).round(),
        (json['fills'][0]['color']['b'] * 255.0).round(),
        json['fills'][0]['opacity'].toDouble()
    );
    return FigmaTextSegmentModel(
        json['characters'],
        json['start'].toInt(),
        json['end'].toInt(),
        json['fontSize'].toDouble(),
        FigmaFontName.fromJson(json['fontName']),
        weight,
        FigmaTextDecoration.values.byNameDefault(json['textDecoration'], FigmaTextDecoration.none),
        FigmaTextCase.values.byNameDefault(json['textCase'], FigmaTextCase.original),
        FigmaTextValue.fromJson(json['lineHeight']),
        FigmaTextValue.fromJson(json['letterSpacing']),
        color,
        FigmaTextListOptionsModel.fromJson(json['listOptions']),
        json['indentation'].toInt(),
        json['hyperlink'] == null ? null : FigmaTextHyperlinkTarget.fromJson(json['hyperlink']),
    );
  }
}

class FigmaTextModel extends FigmaNodeModel {
  final double opacity;
  final FigmaTextAlignHorizontal alignHorizontal;
  final FigmaTextAlignVertical alignVertical;
  final FigmaTextAutoResize autoResize;
  final FigmaTextTruncation truncation;
  final List<FigmaTextSegmentModel> segments;
  final bool isTextField;

  FigmaTextModel.fromJson(Map<String, dynamic> json):
      opacity = json['opacity'].toDouble(),
      alignHorizontal = FigmaTextAlignHorizontal.values.byNameDefault(json['textAlignHorizontal'], FigmaTextAlignHorizontal.left),
      alignVertical = FigmaTextAlignVertical.values.byNameDefault(json['textAlignVertical'], FigmaTextAlignVertical.top),
      autoResize = FigmaTextAutoResize.values.byNameDefault(json['textAutoResize'], FigmaTextAutoResize.none),
      truncation = FigmaTextTruncation.values.byNameDefault(json['textTruncation'], FigmaTextTruncation.disabled ),
      segments = (json['segments'] as List<dynamic>).map((j) => FigmaTextSegmentModel.fromJson(j as Map<String, dynamic>)).toList(),
      isTextField = json['isTextField'] ?? false,
      super.fromJson(json);
}
