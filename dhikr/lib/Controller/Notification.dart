import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:provider/provider.dart';
import 'package:dhikr/Controller/NameClass.dart';
import 'package:dhikr/Controller/Provider/AllahNamesProvider.dart';
import 'package:dhikr/Controller/Provider/DhirkProvider.dart';
import 'package:dhikr/Controller/Provider/UserSavedProvider.dart';
import 'package:dhikr/ListOfAllName/Dhikrs.dart';
import 'package:dhikr/ListOfAllName/ListOfAllNameInBangla.dart';
import 'package:dhikr/main.dart';

void showNotification(BuildContext context, isEnglishSelected) async {
  DhikrProvider dhikrProvider =
      Provider.of<DhikrProvider>(context, listen: false);
  AllahNamesProvider allahNamesProvider =
      Provider.of<AllahNamesProvider>(context, listen: false);
  UserSaveDuaProvider userSaveDuaProvider =
      Provider.of<UserSaveDuaProvider>(context, listen: false);

  // CustomAddProvider customAddProvider = Provider.of<CustomAddProvider>(context, listen: false);

  List<AllahName> selectedNames = allahNamesProvider.getSelectedNames();
  List<Dhikr> selectedDhikrs = dhikrProvider.getSelectedDhikrs();
  List<NameEntry> userAddedList = userSaveDuaProvider.getSelectedSaved();

  if (selectedNames.isNotEmpty ||
      selectedDhikrs.isNotEmpty ||
      userAddedList.isNotEmpty) {
    final allItems = [...selectedNames, ...selectedDhikrs, ...userAddedList];
    final randomIndex = Random().nextInt(allItems.length);
    final item = allItems[randomIndex];

    String name;
    String meaning;

    if (item is AllahName) {
      name = isEnglishSelected
          ? item.name
          : allahNamesBangla
              .firstWhere((element) => element.name == item.name)
              .name;
      meaning = isEnglishSelected
          ? item.meaning
          : allahNamesBangla
              .firstWhere((element) => element.name == item.name)
              .meaning;
    } else if (item is Dhikr) {
      name = isEnglishSelected
          ? item.name
          : mostCommonDhikrBangla
              .firstWhere((element) => element.name == item.name)
              .name;
      meaning = isEnglishSelected
          ? item.meaning
          : mostCommonDhikrBangla
              .firstWhere((element) => element.name == item.name)
              .meaning;
    } else if (item is NameEntry) {
      name = item.name; // Assuming Dhikr has a 'name' property
      meaning = item.meaning; // Assuming Dhikr has a 'meaning' property
    } else {
      return; // If item is not of type AllahName or Dhikr, exit the function
    }

    if (Platform.isWindows) {
      final notification = LocalNotification(
        title: name,
        body: meaning,
      );

      notification.show();

      // Automatically remove the notification after a specified duration
      Timer(const Duration(seconds: 7), () {
        notification.close();
      });
    } else {
      final int notificationId = Random().nextInt(100000);
      AndroidNotificationChannel channel = AndroidNotificationChannel(
          notificationId.toString(), "High Importance Notifications",
          importance: Importance.max);

      AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(channel.id, channel.name.toString(),
              channelDescription: 'your channel description',
              importance: Importance.high,
              priority: Priority.high,
              ticker: "ticker");

      NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidNotificationDetails);

      Future.delayed(Duration.zero, () {
        flutterLocalNotificationsPlugin.show(
          notificationId,
          name,
          meaning,
          platformChannelSpecifics,
          // payload: 'item x',
        );
      });
      Future.delayed(const Duration(seconds: 5), () {
        flutterLocalNotificationsPlugin.cancel(notificationId);
      });
    }
  }
}
