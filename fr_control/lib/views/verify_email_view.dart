import 'package:flutter/material.dart';
import 'package:fr_control/constants/routes.dart';
import 'package:fr_control/services/auth/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Center(
                child: Column(
                  children: [
                    Text("We've sent you a verification email!",
                        style: GoogleFonts.bebasNeue(fontSize: 30)),
                    const SizedBox(height: 10),
                    const Text(
                        "Please click the link provided in the email to verify your account."),
                    const SizedBox(height: 20),
                    // In case you haven't received the email
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                            "If you haven't received a verification email yet,"),
                        TextButton(
                          onPressed: () async {
                            await AuthService.firebase()
                                .sendEmailVerification();
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'click here!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () async {
                        await AuthService.firebase().logOut();
                        navigator.pushNamedAndRemoveUntil(
                          loginRoute,
                          (route) => false,
                        );
                      },
                      child: const Text(
                        'Go back to Login screen',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
