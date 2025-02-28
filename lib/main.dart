import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import win32_fix.dart trước để fix lỗi win32
import 'utils/win32_fix.dart';

// Import providers.dart trước để fix lỗi win32
import 'providers/providers.dart';

import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:hid_listener/hid_listener.dart';
import 'package:macos_window_utils/macos_window_utils.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'providers/language_provider.dart';

void main() async {
  // ensure flutter plugins are intialized and ready to use
  WidgetsFlutterBinding.ensureInitialized();
  await Window.initialize();
  await windowManager.ensureInitialized();

  if (getListenerBackend() != null) {
    if (!getListenerBackend()!.initialize()) {
      print("Failed to initialize listener backend");
    }
  } else {
    print("No listener backend for this platform");
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: const KeyvizApp(),
    ),
  );

  _initWindow();
}

_initWindow() async {
  await windowManager.waitUntilReadyToShow(
    WindowOptions(
      skipTaskbar: true,
      alwaysOnTop: true,
      fullScreen: !Platform.isMacOS,
      titleBarStyle: TitleBarStyle.hidden,
    ),
    () async {
      windowManager.setIgnoreMouseEvents(true);
      windowManager.setHasShadow(false);
      windowManager.setAsFrameless();
    },
  );

  if (Platform.isMacOS) {
    WindowManipulator.makeWindowFullyTransparent();
    await WindowManipulator.zoomWindow();
  } else {
    Window.setEffect(
      effect: WindowEffect.transparent,
      color: Colors.transparent,
    );
  }
  windowManager.blur();
}
