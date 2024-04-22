import 'dart:convert';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_ve_sdk/auth/firebase.auth.dart';
import 'package:flutter_ve_sdk/auth/google.auth.dart';
import 'package:flutter_ve_sdk/routes/routes.dart';
import 'package:flutter_ve_sdk/screens/ForgotPassword.dart';
import 'package:flutter_ve_sdk/screens/Home.dart';
import 'package:flutter_ve_sdk/screens/Interests.dart';
import 'package:flutter_ve_sdk/screens/signup.dart';
import 'package:flutter_ve_sdk/screens/startPage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

String password = '';
dynamic errorMessageEmail;
dynamic errorMessagePassword;

class Login extends StatefulWidget {
  Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;
  late MyDataContainer dataContainer;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });
    String apiUrl = "${dotenv.env['BACKEND_URL']}/login";
    // String apiUrl = "http://192.168.1.16:4000/login";

    try {
      final response = await http.post(Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(<String, dynamic>{
            "email": _emailController.text,
            "password": _passwordController.text,
          }));
      print(_emailController.text);
      print(_passwordController.text);
      print(response.statusCode);

      if (response.statusCode == 200) {
        // Login successful, process the response data
        // print(myData.id);

        final data = json.decode(response.body);

        /// creating a instance of shared preference to store token
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('Authorization', data['token']);

        print("Token ${prefs.getString('Authorization')}");

        dataContainer.updateData(
            data["userData"]["_id"],
            data["userData"]["name"],
            data["userData"]["profilePic"],
            data["userData"]["fancyId"],
            data["userData"]["email"],
            data["userData"]["socialId"],
            List<String>.from(data["userData"]["interests"]));
        print("profilepic ${data["userData"]["profilePic"]}");
        print(
            "profile pic ${Provider.of<MyDataContainer>(context, listen: false).profilePic}");

        setState(() {
          _isLoading = false;
        });
        signIn(email, password);
        // Handle the response data according to your needs
        // e.g., store user data in shared preferences, navigate to home screen, etc.
      } else {
        // Other error occurred
        // Handle the error accordingly
        final data = json.decode(response.body);
        print(data['msg']);
        setState(() {
          _isLoading = false;
        });
        ElegantNotification.error(
                toastDuration: const Duration(milliseconds: 2000),
                title: const Text("Error"),
                description: Text(data['msg']))
            .show(context);
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print("catch");
      // Error occurred during the API call
      // Handle the error accordingly
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      accountExists = true;
    });
    dataContainer = Provider.of<MyDataContainer>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: const Color(0xFF0E0B1F),
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 80.h,
            ),
            Text(
              "SIGN IN",
              style: GoogleFonts.roboto(
                  fontSize: 36.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 70.h,
            ),
            SizedBox(
              width: 295.w,
              child: TextFormField(
                onChanged: (value) async {
                  setState(() {
                    if (value == '') {
                      errorMessageEmail = null;
                    } else if (value.contains(' ')) {
                      errorMessageEmail = "Don't use spaces when writing email";
                    } else if (!emailRegExp.hasMatch(value)) {
                      errorMessageEmail = 'Invalid email address';
                    } else {
                      errorMessageEmail = null;
                      email = value;
                    }
                  });
                },
                controller: _emailController,
                decoration: InputDecoration(
                    errorText: errorMessageEmail,
                    //contentPadding: EdgeInsets.only(bottom: 15),
                    prefixIcon: const Icon(
                      Icons.alternate_email_sharp,
                      color: Colors.white,
                      size: 20,
                    ),
                    hintText: 'E-Mail',
                    hintStyle: const TextStyle(
                      fontSize: 15,
                      color: Colors.white54,
                    ),
                    enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF9F9F9F)))),
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(
              height: 36.h,
            ),
            SizedBox(
              width: 295.w,
              child: TextFormField(
                onChanged: (value) {
                  setState(() {
                    if (value.isEmpty)
                      errorMessagePassword = null;
                    else if (value.contains(' ')) {
                      errorMessagePassword =
                          "Don't use spaces when writing password";
                    } else {
                      password = value;
                      errorMessagePassword = null;
                    }
                  });
                },
                obscureText: !_showPassword,
                controller: _passwordController,
                decoration: InputDecoration(
                    errorText: errorMessagePassword,
                    //contentPadding: EdgeInsets.only(bottom: 10),
                    prefixIcon: const Icon(
                      Icons.lock,
                      color: Colors.white,
                      size: 20,
                    ),
                    hintText: 'Password',
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
                          color: Colors.white,
                          size: 20,
                        )),
                    hintStyle: const TextStyle(
                      fontSize: 15,
                      color: Colors.white54,
                    ),
                    enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF9F9F9F)))),
                keyboardType: TextInputType.visiblePassword,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(
              height: 36.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                    child: const Text(
                      "Don't have an account?",
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      setState(() {
                        accountExists = false;
                      });
                      Navigator.of(context)
                          .pushReplacement(leftToRightAnimation(SignUp()));
                    }),
                GestureDetector(
                  onTap: () => Navigator.of(context)
                      .push(rightToLeftAnimation(const ForgotPassword())),
                  child: Text(
                    "Forgot Password?",
                    style: GoogleFonts.roboto(
                        color: const Color(0xFFEEEEEE),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.normal),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 60.h,
            ),
            SizedBox(
              height: 46.h,
              width: 295.w,
              child: ElevatedButton(
                onPressed: () async {
                  signIn(email, password);
                },
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color(0xFFCBFB5E))),
                child: _isLoading
                    ? const Center(
                        child: SizedBox(
                            height: 30,
                            width: 30,
                            child:
                                CircularProgressIndicator(color: Colors.black)),
                      )
                    : Text(
                        "SIGN IN",
                        style: GoogleFonts.roboto(
                            color: const Color(0xFF20242F),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            SizedBox(
              height: 134.h,
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
                    // signInWithFacebook();
                    // setState(() {});
                    // _login(email);
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
                     setState(() {});
                    _login();
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
          ],
        ),
      ),
    );
  }

  void signIn(String email, String password) async {
    User? user = await signInWithPasswordAndEmail(email, password,context);
    if (user != null) {
      if(accountExists == true){
        _login();
        Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>  BottomNavBar(Home()),
      ));
      }else 
       Navigator.of(context).push(MaterialPageRoute(builder: (context) => Interests(),));
    }
  }
}
