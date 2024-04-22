import 'package:flutter/material.dart';

import 'AboutYou.dart';
import 'Chatlist.dart';
import 'CreateVideoNew.dart';
import 'Home.dart';
import 'VideoSet.dart';
import 'package:flutter_ve_sdk/main.dart';

class BottomNavBar extends StatefulWidget {
  Widget _body;
  BottomNavBar(this._body, {super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

int _selectedIndex = 0;

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget._body,
      bottomNavigationBar: BottomNavigationBar(
        enableFeedback: false,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF0E0B1F),
        fixedColor: Colors.white,
        currentIndex: _selectedIndex,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                color: Colors.white,
              ),
              activeIcon: Icon(Icons.home, color: Color(0xFF1EA7D7)),
              label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.videocam_rounded, color: Colors.white),
              label: "",
              activeIcon: Icon(
                Icons.videocam_rounded,
                color: Color(0xFF1EA7D7),
              )),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.add_circle_rounded,
                color: Colors.white,
              ),
              activeIcon: Icon(
                Icons.add_circle,
                color: Colors.blue,
              ),
              label: ''),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.chat_bubble,
                color: Colors.white,
              ),
              activeIcon: Icon(
                Icons.chat_bubble,
                color: Colors.blue,
              ),
              label: ''),
          BottomNavigationBarItem(
              activeIcon: Icon(
                Icons.account_circle,
                color: Colors.blue,
              ),
              icon: Icon(Icons.account_circle, color: Colors.white),
              label: '')
        ],
        onTap: (value) => setState(() {
          _selectedIndex = value;
          switch (_selectedIndex) {
            case 0:
              widget._body = const Home();
              break;
            case 1:
              widget._body = VideoSet(cameras: cameras);
              break;
            case 2:
              widget._body = CreateVideoNew(cameras: cameras);
              break;
            case 3:
              widget._body = const ChatList();
              break;
            case 4:
              widget._body = const AboutYou();
          }
        }),
      ),
    );
  }
}
