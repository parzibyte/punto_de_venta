import 'package:flutter/material.dart';

showAlertDialog(BuildContext context, Widget cancelButton,
    Widget continueButton, String titulo, String contenido) {
  AlertDialog alert = AlertDialog(
    title: Text(titulo),
    content: Text(contenido),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
