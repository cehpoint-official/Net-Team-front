import 'dart:convert';

import 'package:elegant_notification/elegant_notification.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_ve_sdk/auth/firebase.auth.dart';
import 'package:flutter_ve_sdk/auth/google.auth.dart';
import 'package:flutter_ve_sdk/routes/routes.dart';
import 'package:flutter_ve_sdk/screens/Home.dart';
import 'package:flutter_ve_sdk/screens/Interests.dart';
import 'package:flutter_ve_sdk/screens/login.dart';
import 'package:flutter_ve_sdk/screens/startPage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../main.dart';

String passwordSignUp = '';
String emailSignUp = '';
String nameSignUp = '';

dynamic errorMessageName;
dynamic errorMessageEmail;
dynamic errorMessagePassword;
dynamic errorMessagePassword1;

class SignUp extends StatefulWidget {
  SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordController1 = TextEditingController();
  var _showPassword = false;
  var _showPassword1 = false;
  bool _isError = false;
  bool _isEmailError = false;

  String password1 = '';

  late MyDataContainer dataContainer;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool isValidEmail(String email) {
    return EmailValidator.validate(email);
  }

  Future<void> signUp(String username, String email, String password) async {
    setState(() {
      _isLoading = true;
    });
    var url = Uri.parse('${dotenv.env['BACKEND_URL']}/signup');
    print(username);
    print(email);
    print(password);

    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': username,
          'email': email,
          'password': password,
        }),
      );
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        setState(() {
          _isLoading = false;
        });
        print("signup response ${response.body}");
        // Signup successful
        print('Signup successful');
        ElegantNotification.success(
                title: const Text("Success"),
                description: const Text("Account created successfully"))
            .show(context);
        dataContainer.updateData(
            json.decode(response.body)["_ID"] ?? "", "", "", "", "", "", []);
        Navigator.pop(context);
        Navigator.pushNamed(context, "/interests");
      } else {
        setState(() {
          _isLoading = false;
        });
        // Signup failed
        ElegantNotification.error(
                title: const Text("Error"),
                description: const Text("Error creating user account"))
            .show(context);
        print('Signup failed with status code: ${response.statusCode}');
        print('Error message: ${response.body}');
      }
    } catch (e) {
      ElegantNotification.error(
              title: const Text("Error"),
              description: const Text("Error creating user account"))
          .show(context);
      setState(() {
        _isLoading = false;
      });
      print("error ${e}");
    }
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      accountExists = false;
    });
    dataContainer = Provider.of<MyDataContainer>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0E0B1F),
      body: SafeArea(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 40.w),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 80.h,
                ),
                Text(
                  "SIGN UP",
                  style: GoogleFonts.roboto(
                      fontSize: 36.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 50.h,
                ),
                SizedBox(
                  width: 295.w,
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                        //contentPadding: EdgeInsets.only(bottom: 15),
                        prefixIcon: const Icon(
                          Icons.account_circle_outlined,
                          color: Color(0xFF9F9F9F),
                          size: 20,
                        ),
                        hintText: 'Name',
                        errorText: errorMessageName,
                        hintStyle: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF9F9F9F),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF9F9F9F)))),
                    keyboardType: TextInputType.name,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) {
                      setState(() {
                        if (_nameController.text.length == 0) {
                          errorMessageName = null;
                        } else if (_nameController.text.length < 3 ||
                            _nameController.text.length > 15)
                          errorMessageName = 'Name should contain 3-15 letters';
                        else {
                          nameSignUp = _nameController.text;
                          errorMessageName = null;
                          print('$nameSignUp -------------- USER NAME');
                        }
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 295.w,
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                        //contentPadding: EdgeInsets.only(bottom: 15),
                        prefixIcon: const Icon(
                          Icons.alternate_email_outlined,
                          color: Color(0xFF9F9F9F),
                          size: 20,
                        ),
                        hintText: 'Email',
                        errorText: errorMessageEmail,
                        hintStyle: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF9F9F9F),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF9F9F9F)))),
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) {
                      setState(() {
                        if (value == '') {
                          errorMessageEmail = null;
                        } else if (value.contains(' ')) {
                          errorMessageEmail =
                              "Don't use spaces when writing email";
                        } else if (!emailRegExp.hasMatch(value)) {
                          errorMessageEmail = 'Invalid email address';
                        } else {
                          errorMessageEmail = null;
                          emailSignUp = value;
                          print('$emailSignUp -------------- EMAIL');
                        }
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: 18.h,
                ),
                SizedBox(
                  width: 295.w,
                  child: TextField(
                    obscureText: !_showPassword,
                    controller: _passwordController,
                    decoration: InputDecoration(
                        //contentPadding: EdgeInsets.only(bottom: 10),
                        prefixIcon: const Icon(
                          Icons.lock,
                          color: Color(0xFF9F9F9F),
                          size: 20,
                        ),
                        hintText: 'Password',
                        errorText: errorMessagePassword,
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                            icon: Icon(
                              _showPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: const Color(0xFF9F9F9F),
                              size: 20,
                            )),
                        hintStyle: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF9F9F9F),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF9F9F9F)))),
                    keyboardType: TextInputType.visiblePassword,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) {
                      setState(() {
                        if (value.isEmpty)
                          errorMessagePassword = null;
                        else if (value.contains(' ')) {
                          errorMessagePassword =
                              "Don't use spaces when writing password";
                        } else if (!value.contains(RegExp(r'[A-Z]'))) {
                          errorMessagePassword =
                              'Password should contain at least one letter from [A-Z]';
                        } else if (value.length < 8) {
                          errorMessagePassword =
                              'Password should contain at least 8 characters';
                        } else {
                          passwordSignUp = value;
                          errorMessagePassword = null;
                        }
                      });
                      setState(() {
                        _isError = false;
                        passwordSignUp = _passwordController.text;
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: 18.h,
                ),
                SizedBox(
                  width: 295.w,
                  child: TextField(
                    obscureText: !_showPassword1,
                    controller: _passwordController1,
                    decoration: InputDecoration(
                        //contentPadding: EdgeInsets.only(bottom: 10),
                        prefixIcon: const Icon(
                          Icons.lock,
                          color: Color(0xFF9F9F9F),
                          size: 20,
                        ),
                        hintText: 'Confirm Password',
                        errorText: errorMessagePassword1,
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _showPassword1 = !_showPassword1;
                              });
                            },
                            icon: Icon(
                              _showPassword1
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: const Color(0xFF9F9F9F),
                              size: 20,
                            )),
                        hintStyle: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF9F9F9F),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF9F9F9F)))),
                    keyboardType: TextInputType.visiblePassword,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) {
                      setState(() {
                        if (_passwordController1.text.length == 0) {
                          errorMessagePassword1 = null;
                        } else if (!(_passwordController1.text ==
                            passwordSignUp)) {
                          errorMessagePassword1 = "Passwords aren't same";
                        } else {
                          errorMessagePassword1 = null;
                          password1 = passwordSignUp;
                        }
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: 80.h,
                ),
                SizedBox(
                  height: 46.h,
                  width: 295.w,
                  child: ElevatedButton(
                    onPressed: () {
                      if (passwordSignUp == password1) {
                        print('$nameSignUp $emailSignUp $passwordSignUp');
                        signUp(nameSignUp, emailSignUp, passwordSignUp);
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const Interests(),
                        ));
                      }
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            const Color(0xFFCBFB5E))),
                    child: _isLoading
                        ? const Center(
                            child: SizedBox(
                                height: 30,
                                width: 30,
                                child: CircularProgressIndicator(
                                    color: Colors.black)),
                          )
                        : Text(
                            "SIGN UP",
                            style: GoogleFonts.roboto(
                                color: const Color(0xFF20242F),
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                SizedBox(
                  height: 40.h,
                ),
                Row(
                  children: [
                    const Expanded(
                        child: Divider(
                      color: Color(0xFF8D92A3),
                    )),
                    Text(
                      "    Or connect with    ",
                      style: GoogleFonts.roboto(
                        color: const Color(0xFF8D92A3),
                        fontWeight: FontWeight.bold,
                        fontSize: 11.sp,
                      ),
                    ),
                    const Expanded(
                        child: Divider(
                      color: Color(0xFF8D92A3),
                    )),
                  ],
                ),
                SizedBox(
                  height: 10.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.facebook,
                        color: Colors.white,
                        size: 40.h,
                      ),
                      onPressed: () {
                        //Handle respective event
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.g_mobiledata,
                        color: Colors.white,
                        size: 50.h,
                      ),
                      onPressed: () {
                        signInWithGoogle(context);
                        //Handle respective event
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.apple,
                        color: Colors.white,
                        size: 40.h,
                      ),
                      onPressed: () {
                        //Handle respective event
                      },
                    )
                  ],
                ),
                SizedBox(
                  height: 50.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: GoogleFonts.roboto(
                          fontSize: 14.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.normal),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          accountExists = true;
                          signUpWithEmailAndPassword(
                              emailSignUp, passwordSignUp, context);
                        });
                        Navigator.pushReplacement(
                            context, rightToLeftAnimation(Login()));
                      },
                      child: Text(
                        "Sign In",
                        style: GoogleFonts.roboto(
                            color: const Color(0xFFCBFB5E),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void signUpWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    Future<User?> user = signUpWithPasswordAndEmail(email, password, context);
    if (user != null) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => Interests(),
      ));
    }
  }
}
