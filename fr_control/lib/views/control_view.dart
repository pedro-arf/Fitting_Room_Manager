import 'package:flutter/material.dart';
import 'package:fr_control/constants/routes.dart';
import 'package:fr_control/services/auth/auth_service.dart';
import '../enums/menu_action.dart';

class ControlView extends StatefulWidget {
  const ControlView({Key? key}) : super(key: key);

  @override
  State<ControlView> createState() => _ControlViewState();
}

class _ControlViewState extends State<ControlView> {
  var appBarHeight = AppBar().preferredSize.height;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<MenuAction>(
            offset: Offset(0.0, appBarHeight),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
            onSelected: (value) async {
              final navigator = Navigator.of(context);
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    await AuthService.firebase().logOut();
                    navigator.pushNamedAndRemoveUntil(
                      loginRoute,
                      (_) => false,
                    );
                  }
              }
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: ListTile(
                    minLeadingWidth: 0,
                    horizontalTitleGap: 5,
                    leading: Icon(Icons.logout),
                    title: Text("Logout"),
                    contentPadding: EdgeInsets.all(0),
                  ),
                )
              ];
            },
          )
        ],
      ),
      body: const SafeArea(
        child: Center(child: Text('Logged in')),
      ),
    );
  }
}

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
