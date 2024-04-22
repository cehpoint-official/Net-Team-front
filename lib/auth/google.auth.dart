import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ve_sdk/main.dart';
import 'package:google_sign_in/google_sign_in.dart';

// signInWithGoogle(BuildContext context)async{
//   FirebaseAuth auth = FirebaseAuth.instance;
//   try {
//    final GoogleSignIn googleSignIn = GoogleSignIn();


//   final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

//   if(googleSignInAccount != null){
//     final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

//     final AuthCredential credential = GoogleAuthProvider.credential(
//       idToken: googleSignInAuthentication.idToken,
//       accessToken: googleSignInAuthentication.accessToken
//     );

//     await auth.signInWithCredential(credential);
//     
// }
// catch(e){
//   print(e);
// }
// }

Future<UserCredential> signInWithGoogle(BuildContext context) async {
  // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  email = googleUser!.email;

  return await FirebaseAuth.instance.signInWithCredential(credential);
}