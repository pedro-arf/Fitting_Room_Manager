import 'package:flutter/material.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text(
              'Log out',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      );
    },
  ).then((value) => value ?? false); // ou retorna o showDialog ou retorna falso
}
