import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_ve_sdk/audio_browser.dart';
import 'package:flutter_ve_sdk/screens/splashscreen.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'firebase_options.dart';

String email = '';

bool accountExists = true;
RegExp emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');
FirebaseAuth auth = FirebaseAuth.instance;

class MyDataContainer extends ChangeNotifier {
  String id = "";
  String name = "";
  String profilePic = "";
  String userId = "";
  String userEmail = "";
  String socialUrl = "";
  List<String> interests = [];

  void updateData(
      String newId,
      String newName,
      String newProfilePic,
      String newUserId,
      String newUserEmail,
      String newSocialUrl,
      List<String> newInterests) {
    id = newId;
    name = newName;
    profilePic = newProfilePic;
    userId = newUserId;
    userEmail = newUserEmail;
    socialUrl = newSocialUrl;
    interests.addAll(newInterests);
    notifyListeners();
  }
} 

late QuerySnapshot snapshot;
final db = FirebaseFirestore.instance;
List<CameraDescription> cameras = [];

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'App',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");
  cameras = await availableCameras();
  runApp(
    ChangeNotifierProvider(
      create: (context) => MyDataContainer(),
      child: MyApp(
        cameras: cameras,
      ),
    ),
  );
}

/// The entry point for Audio Browser implementation
@pragma('vm:entry-point')
void audioBrowser() => runApp(AudioBrowserWidget());

class MyApp extends StatefulWidget {
  MyApp({
    Key? key,
    required this.cameras,
  }) : super(key: key);
  final List<CameraDescription> cameras;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void> getDatabase() async {
    setState(() {});
  }

  @override
  void initState() {
    getDatabase();

    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return GetMaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'NetTeam',
              home: Scaffold(
                body: Container(
                  decoration: BoxDecoration(color: Colors.transparent),
                  child: SplashScreen(),
                ),
              ));
        });
  }
}
