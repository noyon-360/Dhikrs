import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:launch_at_startup/launch_at_startup.dart';

import 'package:local_notifier/local_notifier.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:dhikr/Controller/Provider/AllahNamesProvider.dart';
import 'package:dhikr/Controller/Provider/CustomAddProvider.dart';
import 'package:dhikr/Controller/Provider/DhirkProvider.dart';
import 'package:dhikr/Controller/Provider/TimerProvider.dart';
import 'package:dhikr/Controller/Provider/UserSavedProvider.dart';
import 'package:dhikr/ListOfAllName/Dhikrs.dart';
import 'package:dhikr/ListOfAllName/ListOfName.dart';
import 'package:dhikr/Screens/HomeScreen.dart';
import 'package:window_manager/window_manager.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize window manager for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
  }

// Initialize local notifier for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await localNotifier.setup(
      appName: 'Dhikr',
      shortcutPolicy: ShortcutPolicy.requireCreate,
    );
    WindowManager.instance.setMinimumSize(const Size(1024, 768));
  }

  if (!kIsWeb && !Platform.isAndroid && !Platform.isIOS) {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    launchAtStartup.setup(
      appName: packageInfo.appName,
      appPath: Platform.resolvedExecutable,
      packageName: 'dev.leanflutter.examples.launchatstartupexample',
      args: <String>['--minimized']
    );
    
    // await TrayManager.instance.setIcon("Assets/Images/Dhikr Logo.ico");
    await launchAtStartup.enable();
    // await launchAtStartup.disable();
  }

  if (Platform.isAndroid || Platform.isIOS) {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    DarwinInitializationSettings initializationSettingsDarwin =
        const DarwinInitializationSettings();

    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open');

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
            linux: initializationSettingsLinux,
            macOS: initializationSettingsDarwin);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CustomAddProvider()),
        ChangeNotifierProvider(create: (_) => TimerProvider()),
        ChangeNotifierProvider(create: (_) => AllahNamesProvider(allahNames)),
        ChangeNotifierProvider(create: (_) => DhikrProvider(mostCommonDhikr)),
        ChangeNotifierProvider(create: (_) => UserSaveDuaProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
