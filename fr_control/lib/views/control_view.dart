import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:fr_control/constants/routes.dart';
import 'package:fr_control/services/auth/auth_service.dart';
import 'package:fr_control/services/cloud/firestore_storage.dart';
import 'package:fr_control/views/control_list_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../enums/menu_action.dart';

class ControlView extends StatefulWidget {
  const ControlView({Key? key}) : super(key: key);

  @override
  State<ControlView> createState() => _ControlViewState();
}

class _ControlViewState extends State<ControlView> with WidgetsBindingObserver {
  AppLifecycleState appLifecycleState = AppLifecycleState.detached;
  late final FirestoreStorage _tagManager;
  var appBarHeight = AppBar().preferredSize.height;

  @override
  void initState() {
    _tagManager = FirestoreStorage();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    var appState = 'detached';

    switch (state) {
      case AppLifecycleState.resumed:
        appState = 'resumed';
        setState(appState);
        print("app in resumed");
        break;
      case AppLifecycleState.inactive:
        appState = 'inactive';
        setState(appState);
        print("app in inactive");
        break;
      case AppLifecycleState.paused:
        appState = 'paused';
        setState(appState);
        print("app in paused");
        break;
      case AppLifecycleState.detached:
        setState(appState);
        print("app in detached");
        break;
    }
  }

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
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 37),
              child: Text(
                "Currently in the Fitting Room...",
                style: GoogleFonts.bebasNeue(fontSize: 35),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 50),
            Expanded(
              child: StreamBuilder(
                  stream: _tagManager.allTags(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.active:
                        if (snapshot.hasData) {
                          final allTags =
                              snapshot.data as Iterable<FirestoreTag>;
                          return SingleChildScrollView(
                            child: Column(children: [
                              if (allTags.isNotEmpty) ...[
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 25),
                                    child: Text(
                                      (() {
                                        if (allTags.length == 1) {
                                          return "${allTags.length.toString()} item";
                                        } else if (allTags.isEmpty) {
                                          return "";
                                        }
                                        return "${allTags.length.toString()} items";
                                      })(),
                                      style:
                                          GoogleFonts.bebasNeue(fontSize: 30),
                                    )),
                                SizedBox(
                                  height: 600,
                                  child: ControlListView(
                                    tags: allTags,
                                  ),
                                ),
                              ] else ...[
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 100),
                                  child: Column(
                                    children: [
                                      const Icon(
                                        Icons.check,
                                        size: 200,
                                      ),
                                      Text(
                                        "No items",
                                        style:
                                            GoogleFonts.bebasNeue(fontSize: 30),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ]
                            ]),
                          );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                          );
                        }
                      default:
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        );
                    }
                  }),
            ),
          ],
        ),
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

void setState(state) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.reload();
  prefs.setString('state', state);
}
