import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wine_cloud_app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Enables Crashlytics
  if (kReleaseMode) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  }

  runZonedGuarded(
    () => runApp(const WineCloudApp()),
    _logErrorToCrashlytics,
  );
}

void _logErrorToCrashlytics(Object error, StackTrace? stackTrace) {
  if (kReleaseMode) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }
}
