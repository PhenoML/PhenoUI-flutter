import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget topBar(BuildContext context, [String? title, void Function()? refresh]) {
  List<Widget> children = [];

  if (Navigator.canPop(context)) {
    children.add(IconButton(
      icon: const Icon(Icons.arrow_back),
      color: Colors.white,
      onPressed: () => Navigator.pop(context),
    ));
  }

  if (title != null) {
    children.add(Expanded(
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 21,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ));
  }

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