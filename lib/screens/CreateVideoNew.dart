import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Live.dart';
import 'Video15.dart';
import 'Video3m.dart';
import 'Video60.dart';

class CreateVideoNew extends StatefulWidget {
  const CreateVideoNew({super.key, required this.cameras});
  final List<CameraDescription> cameras;

  @override
  State<CreateVideoNew> createState() => _CreateState();
}

class _CreateState extends State<CreateVideoNew> {
  final PageController _controller = PageController();
  int pageIndex = 0;

  late CameraController controller;
  int cameraIndex = 1;

  //For Camera
  Future<void> accessCam() async {
    controller =
        CameraController(widget.cameras[cameraIndex], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    accessCam();
  }

  @override
  void dispose() async {
    await controller.dispose();
    super.dispose();
  }

  void flipCam() async {
    print("Flipping Camera");
    await controller.dispose();
    setState(() {
      cameraIndex = (cameraIndex == 0) ? 1 : 0;
      accessCam();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            CameraPreview(controller),
            PageView(
              pageSnapping: true,
              controller: _controller,
              onPageChanged: (i) {
                setState(() {
                  pageIndex = i;
                });
              },
              children: [
                Video15(flipCam: flipCam),
                Video60(flipCam: flipCam),
                Video3m(flipCam: flipCam),
                Live(flipCam: flipCam)
              ],
            ),
          ],
        ),
      ),
    );
  }
}
