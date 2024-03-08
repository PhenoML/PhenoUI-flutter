library pheno_ui;

import 'package:mirai/mirai.dart';
import 'package:pheno_ui/parsers/figma_checkbox.dart';
import 'package:pheno_ui/parsers/figma_conditional_checkbox.dart';
import 'package:pheno_ui/parsers/figma_form.dart';
import 'package:pheno_ui/parsers/figma_keep_aspect_ratio.dart';
import 'package:pheno_ui/parsers/figma_safe_area.dart';
import 'package:pheno_ui/parsers/figma_component.dart';
import 'package:pheno_ui/parsers/figma_frame.dart';
import 'package:pheno_ui/parsers/figma_image.dart';
import 'package:pheno_ui/parsers/figma_nav_button.dart';
import 'package:pheno_ui/parsers/figma_rectangle.dart';
import 'package:pheno_ui/parsers/figma_submit_button.dart';
import 'package:pheno_ui/parsers/figma_text.dart';
import 'package:pheno_ui/parsers/figma_tile_child.dart';
import 'package:pheno_ui/parsers/figma_web_view.dart';

import 'interface/strapi.dart';

export 'package:mirai/mirai.dart';
export 'package:pheno_ui/interface/strapi.dart';
export 'package:pheno_ui/widgets/figma_screen_renderer.dart';

Future<void> initializePhenoUi({List<MiraiParser> parsers = const []}) async {
  const List<MiraiParser> defaultParsers = [
    FigmaFrameParser(),
    FigmaTextParser(),
    FigmaImageParser(),
    FigmaRectangleParser(),
    FigmaSafeAreaParser(),
    FigmaNavButtonParser(),
    FigmaComponentParser(),
    FigmaCheckboxParser(),
    FigmaWebViewParser(),
    FigmaConditionalCheckboxParser(),
    FigmaFormParser(),
    FigmaSubmitButtonParser(),
    FigmaKeepAspectRatioParser(),
    FigmaTileChildParser(),
  ];

  // merge the parsers giving priority to the ones passed as argument
  var mergedParsers = <MiraiParser>[...defaultParsers, ...parsers];

  await Mirai.initialize(
      parsers: mergedParsers,
  );
}
