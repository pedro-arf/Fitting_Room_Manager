import 'package:flutter/material.dart';
import 'package:fr_control/constants/routes.dart';
import 'package:fr_control/services/auth/auth_service.dart';
import 'package:fr_control/services/cloud/firestore_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import '../enums/menu_action.dart';

class ControlView extends StatefulWidget {
  const ControlView({Key? key}) : super(key: key);

  @override
  State<ControlView> createState() => _ControlViewState();
}

class _ControlViewState extends State<ControlView> {
  late final FirestoreStorage _tagManager;

  @override
  void initState() {
    _tagManager = FirestoreStorage();
    super.initState();
  }

  var appBarHeight = AppBar().preferredSize.height;

  @override
  Widget build(BuildContext context) {
    var screenSizing = MediaQuery.of(context).size;

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
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Text(
                "Currently in the Fitting Room...",
                style: GoogleFonts.bebasNeue(fontSize: 35),
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
                          return Column(
                            children: [
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25),
                                  child: Text(
                                    (() {
                                      if (allTags.length == 1) {
                                        return "${allTags.length.toString()} piece";
                                      }
                                      return "${allTags.length.toString()} pieces";
                                    })(),
                                    style: GoogleFonts.bebasNeue(fontSize: 30),
                                  )),
                              SizedBox(
                                height: 450,
                                child: ListView.builder(
                                  itemCount: allTags.length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    final tag = allTags.elementAt(index);
                                    return Column(
                                      children: [
                                        const SizedBox(
                                          height: 50,
                                        ),
                                        Text(
                                          tag.description,
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Container(
                                          width: screenSizing.width,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 80),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.network(
                                              tag.imgUrl,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Size: ${tag.size}",
                                              style:
                                                  const TextStyle(fontSize: 15),
                                            ),
                                            const SizedBox(
                                              width: 90,
                                            ),
                                            Text("Price: \$${tag.price}",
                                                style: const TextStyle(
                                                    fontSize: 15)),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        } else {
                          return const CircularProgressIndicator();
                        }
                      default:
                        return const CircularProgressIndicator();
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
