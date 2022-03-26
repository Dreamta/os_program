import 'package:flutter/material.dart';

Widget algButton({
  required String text,
  required void Function()? onPressed,
}) {
  return TextButton(
      onPressed: onPressed,
      child: Text(text,
          style: TextStyle(
            fontSize: 20,
          )));
}
