import 'package:flutter/material.dart';

Widget loadingScreen() {
  return const Center(
    child: CircularProgressIndicator(
      color: Colors.blueGrey,
      strokeWidth: 11.0,
      strokeCap: StrokeCap.round,
    ),
  );
}