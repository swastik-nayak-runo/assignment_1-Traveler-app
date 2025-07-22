import 'package:flutter/material.dart';

Future<bool?> showConfirmDeleteDialog(BuildContext context, String tripName, String label) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true, // user must choose
    builder: (ctx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
        title:  Text(
          "Delete $label?",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Do you want to delete the trip \"$tripName\" while you can still edit it?",
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
            child: const Text("Yes, delete the trip", style: TextStyle(color: Colors.white),),
          ),
        ],
      );
    },
  );
}
