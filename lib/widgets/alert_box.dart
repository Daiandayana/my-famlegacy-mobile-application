import 'package:flutter/material.dart';

class AlertBox extends StatelessWidget {
  final String type, object;

  const AlertBox({
    super.key,
    required this.type,
    required this.object,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(type),
      content: Text(object),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
