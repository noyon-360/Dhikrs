import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dhikr/Clock/ClockFace.dart';
import 'package:dhikr/Helper/Color.dart';
import 'package:dhikr/Screens/ListOfDhikrs.dart';
import 'package:tray_manager/tray_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TrayListener {

  @override
  void initState() {
    super.initState();
    trayManager.addListener(this);
  }

  @override
  void dispose() {
    // trayManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: AppColors.primaryColor,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: const BoxDecoration(),
                    child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.0),
                        child: ClockFace()),
                  ),
                ),
                if (!Platform.isAndroid && !Platform.isIOS && !kIsWeb)
                  Expanded(
                      flex: 1,
                      child: Container(
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Color(0xFFF2F2F2)),
                        child: Center(child: Listofdhikrs(isEmbedded: true)),
                      ))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
