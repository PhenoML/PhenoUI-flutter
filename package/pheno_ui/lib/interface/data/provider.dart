
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:pheno_ui/interface/data/screen_spec.dart';

import 'component_spec.dart';
import 'entry.dart';

abstract class PhenoDataProvider {
  final String sourceId;
  final String category;

  final Map<int, Future<PhenoScreenSpec>> _screenSpecCache = {};
  final Map<String, Future<PhenoComponentSpec>> _componentSpecCache = {};
  final Map<String, Future<LottieComposition>> _animationCache = {};
  List<PhenoDataEntry>? _screenList;

  PhenoDataProvider({
    required this.sourceId,
    required this.category,
  });

  @nonVirtual
  void clearCache() {
    _screenSpecCache.clear();
    _componentSpecCache.clear();
    // _screenList = null; // do not clear screen list
  }

  @nonVirtual
  Future<List<PhenoDataEntry>> getScreenList([bool override = false]) async {
    if (_screenList != null && !override) {
      return _screenList!;
    }
    _screenList = await doGetScreenList();
    return _screenList!;
  }

  @nonVirtual
  Future<PhenoScreenSpec> loadScreenLayout(int id) async {
    if (_screenSpecCache.containsKey(id)) {
      return await _screenSpecCache[id]!;
    }
    final specFuture = doLoadScreenLayout(id);
    _screenSpecCache[id] = specFuture;
    return await specFuture;
  }

  @nonVirtual
  Future<PhenoComponentSpec> loadComponentSpec(String name) async {
    if (_componentSpecCache.containsKey(name)) {
      return await _componentSpecCache[name]!;
    }
    final specFuture =  doLoadComponentSpec(name);
    _componentSpecCache[name] = specFuture;
    return await specFuture;
  }

  @nonVirtual
  Future<LottieComposition> loadAnimation(String path) async {
    if (_animationCache.containsKey(path)) {
      return await _animationCache[path]!;
    }
    final animationFuture = doLoadAnimation(path);
    _animationCache[path] = animationFuture;
    return await animationFuture;
  }

  Future<List<PhenoDataEntry>> doGetScreenList();
  Future<PhenoScreenSpec> doLoadScreenLayout(int id);
  Future<PhenoComponentSpec> doLoadComponentSpec(String name);
  Future<LottieComposition> doLoadAnimation(String path);

  Image loadImage(String path, { required BoxFit fit });
  SvgPicture loadSvg(String path, { required BoxFit fit });
}