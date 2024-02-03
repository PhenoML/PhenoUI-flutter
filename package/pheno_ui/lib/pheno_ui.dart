library pheno_ui;

import 'package:mirai/mirai.dart';
import 'package:pheno_ui/parsers/figma-safe-area.dart';
import 'package:pheno_ui/parsers/figma_frame.dart';
import 'package:pheno_ui/parsers/figma_image.dart';
import 'package:pheno_ui/parsers/figma_nav_button.dart';
import 'package:pheno_ui/parsers/figma_rectangle.dart';
import 'package:pheno_ui/parsers/figma_text.dart';

export 'package:mirai/mirai.dart';
export 'package:pheno_ui/interface/strapi.dart';
export 'package:pheno_ui/interface/figma_screen_renderer.dart';

Future<void> initializePhenoUi() async {
  await Mirai.initialize(
      parsers: [
        const FigmaFrameParser(),
        const FigmaTextParser(),
        const FigmaImageParser(),
        const FigmaRectangleParser(),
        const FigmaSafeAreaParser(),
        const FigmaNavButtonParser(),
      ]
  );
}
