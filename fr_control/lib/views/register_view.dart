import 'package:flutter/material.dart';
import 'package:fr_control/services/auth/auth_exceptions.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/routes.dart';
import '../services/auth/auth_service.dart';
import '../utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  // register controllers
  late final TextEditingController _email;
  late final TextEditingController _password;

  //initiate the register variables
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
                // Sign Up Message
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35),
                    child: Text(
                      'Register',
                      style: GoogleFonts.bebasNeue(fontSize: 40),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),

                // Credentials Message
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 35),
                    child: Text(
                      'Input your credentials below!',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 50,
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
                        await AuthService.firebase().createUser(
                            email: email,
                            password:
                                password); // usamos await para que a app não execute nada antes de fazer a autenticação do user ( a função invoca um Future, logo await)
                        await AuthService.firebase().sendEmailVerification();
                        navigator.pushNamed(verifyEmailRoute);
                      } on WeakPasswordAuthException {
                        await showErrorDialog(
                          context,
                          'Weak password',
                        );
                      } on EmailAlreadyInUseAuthException {
                        await showErrorDialog(
                          context,
                          'Email is already in use',
                        );
                      } on InvalidEmailAuthException {
                        await showErrorDialog(
                          context,
                          'This is an invalid email address',
                        );
                      } on GenericAuthException {
                        await showErrorDialog(
                          context,
                          'Failed to register',
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
                            'Sign up',
                            style: GoogleFonts.bebasNeue(
                                fontSize: 18, color: Colors.white),
                          ),
                        )),
                  ),
                ),
                const SizedBox(height: 30),

                // Already registered?
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already registered?"),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            loginRoute, (route) => false);
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        ' Login here!',
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
