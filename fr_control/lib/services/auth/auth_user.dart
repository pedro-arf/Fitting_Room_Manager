import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/cupertino.dart';

@immutable // internals never gonna be changed uppon initialization (todas as classes que derivam desta, têm de ser imutáveis)
class AuthUser {
  final bool isEmailVerified;

  const AuthUser({required this.isEmailVerified});

  factory AuthUser.fromFirebase(User user) => AuthUser(
      isEmailVerified: user.emailVerified); // factory initializer (contructor)
}
