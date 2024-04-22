import 'package:flutter/material.dart';
import 'package:flutter_ve_sdk/screens/login.dart';
import 'package:flutter_ve_sdk/screens/signup.dart';

// for left to right
PageRouteBuilder<dynamic> leftToRightAnimation(_route) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => _route,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = const Offset(-1.0, 0.0);
      var end = Offset.zero;
      var curve = Curves.easeInOutQuart;
      var tween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: curve),
      );
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

//from right to left
PageRouteBuilder<dynamic> rightToLeftAnimation(_route) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => _route,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = const Offset(1.0, 0.0);
      var end = Offset.zero;
      var curve = Curves.easeInOutQuart;
      var tween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: curve),
      );
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

PageRouteBuilder<dynamic> signUpPageBuilder() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>  SignUp(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = const Offset(0.0, 1.0);
      var end = Offset.zero;
      var curve = Curves.easeInOutQuart;
      var tween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: curve),
      );
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}