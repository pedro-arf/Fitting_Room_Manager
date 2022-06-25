import 'package:flutter/material.dart';
import 'package:fr_control/constants/routes.dart';
import 'package:fr_control/services/auth/auth_exceptions.dart';
import 'package:fr_control/services/auth/auth_service.dart';
import 'package:fr_control/utilities/show_error_dialog.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // login controllers
  late final TextEditingController _email;
  late final TextEditingController _password;

  // sign in method
  Future signIn() async {}

  //initiate the register varibles
  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  // dispose the variables once the page is closed
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App Icon

                const Icon(
                  Icons.thumbs_up_down_sharp,
                  size: 100,
                ),
                const SizedBox(
                  height: 75,
                ),

                // Login Message

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 35),
                  child: Text(
                    'Login',
                    style: GoogleFonts.bebasNeue(fontSize: 40),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),

                // Email Textfield

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 35),
                  child: TextField(
                    controller: _email,
                    style: const TextStyle(fontSize: 18),
                    enableSuggestions: false,
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                        hintText: 'Email',
                        border: UnderlineInputBorder(),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        hintStyle: TextStyle(fontSize: 18)),
                  ),
                ),

                const SizedBox(height: 10),

                // Password Textfield

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 35),
                  child: TextField(
                    controller: _password,
                    style: const TextStyle(fontSize: 18),
                    enableSuggestions: false,
                    autocorrect: false,
                    obscureText: true,
                    decoration: const InputDecoration(
                        hintText: 'Password',
                        border: UnderlineInputBorder(),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        hintStyle: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 30),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 35),
                  child: GestureDetector(
                    onTap: () async {
                      final email = _email.text; // gets text from TextField
                      final password = _password.text;
                      final navigator = Navigator.of(context);
                      try {
                        await AuthService.firebase().logIn(
                          email: email,
                          password: password,
                        );
                        final user = AuthService.firebase().currentUser;
                        if (user?.isEmailVerified ?? false) {
                          //email is verified
                          navigator.pushNamedAndRemoveUntil(
                            controlRoute,
                            (route) => false,
                          );
                        } else {
                          //email is not verified
                          navigator.pushNamedAndRemoveUntil(
                            verifyEmailRoute,
                            (route) => false,
                          );
                        }
                      } on UserNotFoundAuthException {
                        await showErrorDialog(
                          context,
                          'User not found',
                        );
                      } on WrongPasswordAuthException {
                        await showErrorDialog(
                          context,
                          'Wrong credentials',
                        );
                      } on GenericAuthException {
                        await showErrorDialog(
                          context,
                          'Authentication error',
                        );
                      }
                    },
                    child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                          child: Text(
                            'Sign in',
                            style: GoogleFonts.bebasNeue(
                                fontSize: 18, color: Colors.white),
                          ),
                        )),
                  ),
                ),

                const SizedBox(height: 30),

                // Not registered?
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            registerRoute, (route) => false);
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        ' Register here!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
