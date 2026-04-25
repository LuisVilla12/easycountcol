import 'package:flutter/material.dart';

Future<bool?> mostrarDialogo({
  required BuildContext context,
  required String titulo,
  required String mensaje,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Text(titulo),
      content: Text(mensaje),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text("OK"),
        ),
      ],
    ),
  );
}