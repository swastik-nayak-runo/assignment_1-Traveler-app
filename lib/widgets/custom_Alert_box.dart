import 'package:flutter/material.dart';

Future<bool?> showConfirmDeleteDialog(
    BuildContext context,
    String thingName,    // e.g. "Eiffel Tower Tour"
    String label,        // e.g. "Activity Plan"
    ) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
        title: Text(
          "Delete $label?",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Do you want to delete "$thingName"? You can still edit it instead.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text("Yes, delete $label",
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}
