import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:window_manager/window_manager.dart';

enum ContentSize {
  iPhone(393, 852),
  iPhonePlus(430, 932),
  iPad(834, 1194),
  iPadPro(1024, 1366),
  iPadMini(744, 1133),
  iPadLS(1194, 834),
  iPadProLS(1366, 1024),
  iPadMiniLS(1133, 744),
  ;
  final double width;
  final double height;
  const ContentSize(this.width, this.height);
}

const double _kTopBarHeight = 60;

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
    centerChildren.add(Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DropdownMenu<ContentSize>(
          width: 185,
          inputDecorationTheme: InputDecorationTheme(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            constraints: BoxConstraints.tight(const Size.fromHeight(24)),
          ),
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 10,
          ),
          trailingIcon: Transform.translate(
            offset: const Offset(3, -5),
            child: const Icon(Icons.arrow_drop_down, color: Colors.white),
          ),
          onSelected: (ContentSize? value) async {
            if (value != null) {
              // get the window diff from the content size
              var windowSize = await windowManager.getSize();
              var diff = Size(windowSize.width - constraints.maxWidth, windowSize.height - constraints.maxHeight);
              windowManager.setSize(
                  Size(value.width + diff.width, value.height + diff.height + _kTopBarHeight));
            }
          },
          dropdownMenuEntries: ContentSize.values.map((e) => DropdownMenuEntry(
            value: e,
            label: '${e.name} (${e.width.toInt()}x${e.height.toInt()})',
          )).toList(),
        ),
        Text(
          '(${constraints.maxWidth.toInt()}x${constraints.maxHeight.toInt() - _kTopBarHeight.toInt()})',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ]
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
    height: _kTopBarHeight,
    color: Colors.blueGrey,
    padding: const EdgeInsets.only(left: 12, right: 52),
    child: Row(
      children: children,
    ),
  );
}