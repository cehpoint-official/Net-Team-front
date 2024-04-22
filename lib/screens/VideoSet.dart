import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_ve_sdk/screens/videoCall.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'UploadVideoForm.dart';
import '../main.dart';

class VideoSet extends StatefulWidget {
  const VideoSet({Key? key, required this.cameras}) : super(key: key);
  final List<CameraDescription> cameras;

  @override
  State<VideoSet> createState() => _VideoSetState();
}

class _VideoSetState extends State<VideoSet> {
  List<String> interests = [];
  List<String> autoInterests = [];
  bool isError = false;
  late String errMsg;
  late Timer timer;
  late String id;

  TextEditingController _interestController = TextEditingController();

  void _addInterest(String interest) {
    if (interests.length < 3) {
      setState(() {
        interests.add(interest);
        _interestController.clear();
      });
    } else {
      setState(() {
        isError = true;
        errMsg = "You can enter 3 interests only";
      });
      Timer(const Duration(seconds: 3), () {
        setState(() {
          isError = false;
        });
      });
    }
  }

  void _removeInterest(String interest) {
    setState(() {
      interests.remove(interest);
    });
  }

  /// part of video editor sdk
  static const String LICENSE_TOKEN =
      "Qk5CIFHq0X8qP0t0H2ARMhyAH81fEqShGnEsv5+R4QvionjKoVCURuewu3fWI6EgmVu1E+UiRzbmnRSLYPJ60uEPYXIoWmwmoNyIjv5fz8PWZ9ndPQSAWgpZacnOHacCMbXBv6COglX7Rqt0N8dDrnAjPivGGD2l0+C65N9apc3kW5aqDMAlyTwzH+wOjRvDIWuiPUuaRayEx+SdK2parFDHzlyK+BK3kRu/K8QBxygGIZY6/gJhxLdilrwUq4Nm0AJk+yPQMKW5rrGGOKUldV8JFmiHTqDeNZ7pa60MIXGmf3kwf1MbLUH8CQo2Pah74olYOjWpxWBO4dTm88O5EKxSsZBATkXcNTSJ1Cnkfu0BblFCpeQFf4MH6wopPI+RZty9GpMFLpRf0BBDPVRIf9w7btTBqjjcwst86Bo8V7qZagiba8q8KrDYf4pca1CiFChxFoh/lxyppCYSf8jb48Dnpw8RH9rqRgcmO6NuVmhWmMkso1RfoJNJRdz4hl4Qh+jCiYKg/5kEmf7lRYQZzi4G7Y7ZnMPkx6bFNgR7HHeQudFopkbe2aH7BTIH1Z2QFP/uE8B3wkM3FrAWrzHF0gklMXa82tpyXqF1gG42/wWWOl2j6rOUQMDJjSkvqoWelnAAJLsLkNE9SQ8UPyBqeQ=="; // static String? LICENSE_TOKEN = dotenv.env['BANUBA_LICENSE_TOKEN'];

  static const channelName = 'startActivity/VideoEditorChannel';

  static const methodInitVideoEditor = 'InitBanubaVideoEditor';
  static const methodStartVideoEditor = 'StartBanubaVideoEditor';
  static const methodStartVideoEditorPIP = 'StartBanubaVideoEditorPIP';
  static const methodStartVideoEditorTrimmer = 'StartBanubaVideoEditorTrimmer';
  static const methodDemoPlayExportedVideo = 'PlayExportedVideo';

  static const errMissingExportResult = 'ERR_MISSING_EXPORT_RESULT';
  static const errStartPIPMissingVideo = 'ERR_START_PIP_MISSING_VIDEO';
  static const errStartTrimmerMissingVideo = 'ERR_START_TRIMMER_MISSING_VIDEO';
  static const errExportPlayMissingVideo = 'ERR_EXPORT_PLAY_MISSING_VIDEO';

  static const errEditorNotInitializedCode = 'ERR_VIDEO_EDITOR_NOT_INITIALIZED';
  static const errEditorNotInitializedMessage =
      'Banuba Video Editor SDK is not initialized: license token is unknown or incorrect.\nPlease check your license token or contact Banuba';
  static const errEditorLicenseRevokedCode = 'ERR_VIDEO_EDITOR_LICENSE_REVOKED';
  static const errEditorLicenseRevokedMessage =
      'License is revoked or expired. Please contact Banuba https://www.banuba.com/faq/kb-tickets/new';

  static const argExportedVideoFile = 'exportedVideoFilePath';
  static const argExportedVideoCoverPreviewPath =
      'exportedVideoCoverPreviewPath';

  static const platform = MethodChannel(channelName);

  String _errorMessage = '';

  Future<void> _initVideoEditor() async {
    await platform.invokeMethod(methodInitVideoEditor, LICENSE_TOKEN);
  }

  Future<void> _startVideoEditorDefault() async {
    try {
      await _initVideoEditor();

      final result = await platform.invokeMethod(methodStartVideoEditor);

      _handleExportResult(result);
      print(result);
    } on PlatformException catch (e) {
      _handlePlatformException(e);
    }
  }

  void _handleExportResult(dynamic result) {
    debugPrint('Export result = $result');

    // You can use any kind of export result passed from platform.
    // Map is used for this sample to demonstrate playing exported video file.
    if (result is Map) {
      final exportedVideoFilePath = result[argExportedVideoFile];

      // Use video cover preview to meet your requirements
      final exportedVideoCoverPreviewPath =
          result[argExportedVideoCoverPreviewPath];

      print("Edited video path $exportedVideoFilePath");

      /// pass this edited video to form screen
      Get.to(() => VideoUploadForm(
            videoFile: File(exportedVideoFilePath),
          ));

      // _showConfirmation(context, "Play exported video file?", () {
      //   platform.invokeMethod(
      //       methodDemoPlayExportedVideo, exportedVideoFilePath);
      // });
    }
  }

  // Handle exceptions thrown on Android, iOS platform while opening Video Editor SDK
  void _handlePlatformException(PlatformException exception) {
    debugPrint("Error: '${exception.message}'.");

    String errorMessage = '';
    switch (exception.code) {
      case errEditorLicenseRevokedCode:
        errorMessage = errEditorLicenseRevokedMessage;
        break;
      case errEditorNotInitializedCode:
        errorMessage = errEditorNotInitializedMessage;
        break;
      default:
        errorMessage = 'unknown error';
    }

    _errorMessage = errorMessage;
    setState(() {});
  }

  void _showConfirmation(
      BuildContext context, String message, VoidCallback block) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
        actions: [
          MaterialButton(
            color: Colors.red,
            textColor: Colors.white,
            disabledColor: Colors.grey,
            disabledTextColor: Colors.black,
            padding: const EdgeInsets.all(12.0),
            splashColor: Colors.redAccent,
            onPressed: () => {Navigator.pop(context)},
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 14.0,
              ),
            ),
          ),
          MaterialButton(
            color: Colors.green,
            textColor: Colors.white,
            disabledColor: Colors.grey,
            disabledTextColor: Colors.black,
            padding: const EdgeInsets.all(12.0),
            splashColor: Colors.greenAccent,
            onPressed: () {
              Navigator.pop(context);
              block.call();
            },
            child: const Text(
              'Ok',
              style: TextStyle(
                fontSize: 14.0,
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Video Chat",
          style: GoogleFonts.nunito(
              fontSize: 32.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: const Color(0xFF0E0B1F),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 10.h),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 168.h,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Image.asset(
                    "./assets/images/videoChatAvatar.png",
                    height: 168.h,
                  )
                ]),
              ),
              SizedBox(
                height: 30.h,
              ),
              Text(
                "Add your interests",
                style: GoogleFonts.roboto(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              ),
              SizedBox(
                height: 20.h,
              ),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: interests.map((String interest) {
                  return GestureDetector(
                    onDoubleTap: () {
                      _removeInterest(interest);
                    },
                    child: Chip(
                      label: Text(
                        interest,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  );
                }).toList(),
              ),
              Column(children: [
                Padding(
                  padding: EdgeInsets.only(top: 10.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _interestController,
                          decoration: InputDecoration(
                              enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color:
                                          Color.fromRGBO(139, 139, 139, 0.26))),
                              labelText: 'Add Interest',
                              errorText: isError ? errMsg : null,
                              labelStyle: GoogleFonts.roboto(
                                  fontSize: 13.sp,
                                  color: const Color(0xFF979797),
                                  fontWeight: FontWeight.normal)),
                          onFieldSubmitted: (value) {
                            _addInterest(value);
                          },
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        "${interests.length}/3",
                        style: GoogleFonts.roboto(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                            color: Colors.white),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 30.h,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Based on 3 interest details that you added above.",
                        style: GoogleFonts.roboto(
                            fontSize: 13.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    SizedBox(
                      width: 15.w,
                    ),
                    SizedBox(
                      height: 35.h,
                      width: 106.w,
                      child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Color(0xFF14ADD9))),
                        child: Text(
                          "Manual",
                          style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontSize: 12.sp),
                        ),
                        onPressed: () {
                          if (interests.length > 0) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => VideoCall(
                                        cameras: widget.cameras,
                                        interests: interests)));
                          } else {
                            setState(() {
                              errMsg =
                                  "Kindly enter interests for manual matching";
                              isError = true;
                            });
                            Timer(const Duration(seconds: 3), () {
                              setState(() {
                                isError = false;
                              });
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ]),
              SizedBox(
                height: 20.h,
              ),
              Divider(
                color: Colors.grey,
              ),
              SizedBox(
                height: 20.h,
              ),
              Row(
                children: [
                  SizedBox(
                    height: 35.h,
                    width: 135.w,
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Color(0xFFE90818))),
                      child: Text(
                        "Auto Match",
                        style: GoogleFonts.roboto(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontSize: 12.sp),
                      ),
                      onPressed: () {
                        setState(() {
                          autoInterests.addAll(Provider.of<MyDataContainer>(
                                  context,
                                  listen: false)
                              .interests);
                        });
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VideoCall(
                                    cameras: widget.cameras,
                                    interests: autoInterests)));
                      },
                    ),
                  ),
                  SizedBox(
                    width: 15.w,
                  ),
                  Expanded(
                    child: Text(
                      "Based on interest details that you added in your profile.",
                      style: GoogleFonts.roboto(
                          fontSize: 13.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20.h,
              ),
              Divider(
                color: Colors.grey,
              ),
              SizedBox(
                height: 20.h,
              ),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Warning : ",
                      style: GoogleFonts.roboto(
                          fontSize: 13.sp,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 30.h,
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 15.w),
                      child: Column(
                        children: [
                          for (var i = 0;
                              i < 2;
                              i++) // This loop replaces the repeated Row widgets
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: i < 1
                                      ? 10.h
                                      : 0), // Adds space between the warnings, but not after the last one
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${i + 1}.",
                                    style: GoogleFonts.roboto(
                                        fontSize: 13.sp,
                                        color: Colors.orange,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Text(
                                      i == 0
                                          ? "Do not use bad language and be professional"
                                          : "Legal actions could be taken if the users are reported",
                                      style: GoogleFonts.roboto(
                                          fontSize: 13.sp,
                                          color: Colors.orange,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      // bottomNavigationBar: BottomAppBar(
      //   elevation: 0.0,
      //   color: Color(0xFF0E0B1F),
      //   child: SizedBox(
      //     height: 60.h,
      //     child: Row(
      //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //       children: [
      //         GestureDetector(
      //           child: SizedBox(
      //               height: 40.h,
      //               child: Icon(Icons.home,
      //                   size: 30.h, color: const Color(0xFFFFFFFF))),
      //           onTap: () {
      //             Navigator.pushNamed(
      //               context,
      //               "/",
      //             );
      //           },
      //         ),
      //         GestureDetector(
      //           child: SizedBox(
      //               height: 40.h,
      //               child: Icon(Icons.videocam_rounded,
      //                   size: 30.h, color: const Color(0xFF1EA7D7))),
      //           onTap: () {
      //             //Navigate to Video Call
      //             Navigator.pushNamed(
      //               context,
      //               "/videoset",
      //             );
      //           },
      //         ),
      //         GestureDetector(
      //           child: SizedBox(
      //               height: 40.h,
      //               child: Icon(Icons.add_circle_rounded,
      //                   size: 30.h, color: const Color(0xFFFFFFFF))),
      //           onTap: () {
      //             //Navigate to Add tiktok
      //             _startVideoEditorDefault();
      //             // Navigator.pushNamed(context, "/create");
      //           },
      //         ),
      //         GestureDetector(
      //           child: SizedBox(
      //               height: 40.h,
      //               child: Icon(Icons.chat_bubble,
      //                   size: 30.h, color: const Color(0xFFFFFFFF))),
      //           onTap: () {
      //             //Navigate to chat
      //             Navigator.pushNamed(context, "/chatlist");
      //           },
      //         ),
      //         GestureDetector(
      //           child: SizedBox(
      //               height: 40.h,
      //               child: Icon(Icons.account_circle,
      //                   size: 30.h, color: const Color(0xFFFFFFFF))),
      //           onTap: () {
      //             //Navigate to Account section
      //             Navigator.pushNamed(context, "/aboutyou");
      //           },
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}
