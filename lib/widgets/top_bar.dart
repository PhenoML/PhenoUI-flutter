import 'package:flutter/material.dart';

Widget topBar(BuildContext context, [String? title, void Function()? refresh]) {
  List<Widget> children = [];

  if (Navigator.canPop(context)) {
    children.add(Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: Colors.white,
        onPressed: () => Navigator.pop(context),
      ),
    ));
  }

  if (title != null) {
    children.add(Align(
      alignment: Alignment.center,
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 21,
        ),
      ),
    ));
  }

  if (refresh != null) {
    children.add(
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: const Icon(Icons.refresh),
            color: Colors.white,
            onPressed: refresh,
          ),
        )
    );
  }

  return Container(
    height: 60,
    color: Colors.blueGrey,
    padding: const EdgeInsets.only(left: 12, right: 52),
    child: Stack(
      children: children,
    ),
  );
}