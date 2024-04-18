import 'package:flutter/widgets.dart';

import '../interface/route_arguments.dart';
import '../models/figma_component_model.dart';
import 'figma_component.dart';

class FigmaPropsFromRoute {
  static FigmaComponent fromJson(Map<String, dynamic> json) {
    return figmaComponentFromJson(json, FigmaComponent.new, FigmaComponentModel.fromJson, FigmaPropsFromRouteState.new);
  }
}

class FigmaPropsFromRouteState extends FigmaComponentState {
  @override
  void initState() {
    Map<String, dynamic>? props = widget.model.userData.maybeGet('props');
    if (props is Map<String, dynamic>) {
      // Future Dario:
      // this is a hack to get the current route from the navigator...
      // unfortunately getting the modal route at this stage is not possible
      // because `ModalRoute.of(context)` introduces a dependency that
      // cannot be established during `initState` and will crash the app.
      // We could do it in `didChangeDependencies` but that would be too late.
      // Unless we refactor the way components set their variants, this code
      // must run before calling `super.initState()`.
      Navigator.of(context).popUntil((route) {
        var arguments = route.settings.arguments;
        if (arguments is RouteArguments) {
          var data = arguments.data;
          if (data != null) {
            for (var key in props.keys) {
              var value = data[props[key]];
              if (value != null) {
                widget.model.userData.set(key, value);
              }
            }
          }
        }
        // returning true ensures that `popUntil` won't have any effect
        return true;
      });
    }
    super.initState();
  }
}
