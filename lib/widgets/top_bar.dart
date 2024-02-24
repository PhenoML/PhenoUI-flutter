import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

Widget topBar(BuildContext context, [String? title, void Function()? refresh, BoxConstraints? constraints]) {
  List<Widget> children = [];
  if (Navigator.canPop(context)) {
    children.add(IconButton(
      icon: const Icon(Icons.arrow_back),
      color: Colors.white,
      onPressed: () => Navigator.pop(context),
    ));
  }

  var centerChildren = <Widget>[];

  if (title != null) {
    centerChildren.add(Text(
      title,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 21,
        overflow: TextOverflow.ellipsis,
      ),
    ));
  }

  if (constraints != null) {
    centerChildren.add(Text(
      '(${constraints!.maxWidth.toInt()}x${constraints!.maxHeight.toInt() - 60})',
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        overflow: TextOverflow.ellipsis,
      ),
    ));
  }

  children.add(Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: centerChildren
      )
  ));

  if (refresh != null) {
    children.add(
        IconButton(
          icon: const Icon(Icons.refresh),
          color: Colors.white,
          onPressed: refresh,
        )
    );
  }

  return Container(
    height: 60,
    color: Colors.blueGrey,
    padding: const EdgeInsets.only(left: 12, right: 52),
    child: Row(
      children: children,
    ),
  );
}