import 'package:flutter/material.dart';

Color color1 = Color(0xFF435334);
Color color2 = Color(0xFF9EB384);
Color color3 = Color(0xFFCEDEBD);
Color color4 = Color(0xFFFAF1E4);

textStyle1() {
  TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold);
}

textStyle2() {
  TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold);
}

snackBar({
  required BuildContext context,
  required String content,
  required Color color,
  SnackBarAction? snackbarAction,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      elevation: 5,
      content: Text(
        content,
        style: TextStyle(color: Colors.white),
      ),
      duration: Duration(seconds: 2),
      backgroundColor: color,
      action: snackbarAction,
    ),
  );
}
