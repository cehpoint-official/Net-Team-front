import 'package:elegant_notification/elegant_notification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

FirebaseAuth _auth = FirebaseAuth.instance;

Future<User?> signUpWithPasswordAndEmail(String email,String password,BuildContext context) async {
  try {
    UserCredential credential = await  _auth.createUserWithEmailAndPassword(email: email, password: password);
    print(credential.user);
    return credential.user;
  }
  catch(e){
    print("ERROR $e");
  }
  return null;
}

Future<User?> signInWithPasswordAndEmail(String email,String password,BuildContext context) async {
  try {
    UserCredential credential = await  _auth.signInWithEmailAndPassword(email: email, password: password);
    print('${credential.user} --------------------------------------------------------');
    return credential.user;
  }
  on FirebaseAuthException catch (e){
    if(e.code == 'channel-error'){
      ElegantNotification.error(description: Text('Username or password are not correct')).show(context);
    }
  }
  return null;
}