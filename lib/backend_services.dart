import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class EmailAuth {
  Future<UserRec> signIn(String email, String password);
  Future<UserRec> signUp(String username, String email, String password);
  Future<void> signOut();
  Future<String> resetPassword(String email);
}

class UserRec {
  final User user;

  final String message;

  UserRec({this.user, this.message = "N/A"});
}

enum STATE { SUCCESS, ERROR }

class Auth implements EmailAuth {
  STATE state;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  @override
  Future<UserRec> signUp(String username, String email, String password) async {
    print("Signing Up...");
    User user;
    try {
      user = (await _firebaseAuth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user;
      /* FB.UserUpdateInfo info = new FB.UserUpdateInfo();
      info.displayName = username;
      user.updateProfile(info);*/

      await FirebaseAuth.instance.currentUser
          .updateProfile(displayName: username);
      state = STATE.SUCCESS;
    } catch (e) {
      print("An error occured while trying to create an Account");
      state = STATE.ERROR;
      return UserRec(message: e.message);
    }
    try {
      await user.sendEmailVerification();
      state = STATE.SUCCESS;
      return UserRec(user: user, message: "Signed up successfully");
    } catch (e) {
      print("An error occured while trying to send email verification");
      state = STATE.ERROR;
      return UserRec(message: e.message);
    }
  }

  Future<UserRec> sendVerficationLink(User user) async {
    try {
      await user.sendEmailVerification();
      state = STATE.SUCCESS;
      return UserRec(user: user, message: "Signed up successfully");
    } catch (e) {
      print("An error occured while trying to send email verification");
      state = STATE.ERROR;
      return UserRec(message: e.message);
    }
  }

  @override
  Future<UserRec> signIn(String email, String password) async {
    User user;
    try {
      user = (await _firebaseAuth.signInWithEmailAndPassword(
              email: email, password: password))
          .user;

      state = STATE.SUCCESS;
    } catch (e) {
      print("${e.toString()}");
      state = STATE.ERROR;
      return UserRec(message: e.message);
    }
    if (user.emailVerified) {
      return UserRec(user: user, message: "Signed in successfully");
    }
    return UserRec(
        user: user,
        message: "Please check your mail for the verification link");
  }

  @override
  Future<String> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      state = STATE.SUCCESS;
      return "Reset Password link sent";
    } catch (e) {
      print("An error occured while trying to send reset link");
      state = STATE.ERROR;
      return e.message;
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  bool isSignedIn() {
    final currentUser = _firebaseAuth.currentUser;
    return currentUser != null;
  }

  UserRec getUser() {
    return (UserRec(user: _firebaseAuth.currentUser));
  }

  Future<User> getFirebaseUser() async {
    User firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      firebaseUser = await FirebaseAuth.instance.authStateChanges().first;
    }
    return firebaseUser;
  }
}
