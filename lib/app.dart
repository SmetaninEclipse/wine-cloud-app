import 'package:flutter/material.dart';
import 'package:wine_cloud_app/features/esp_connector.dart';

class WineCloudApp extends StatefulWidget {
  const WineCloudApp({super.key});

  @override
  State<WineCloudApp> createState() => _WineCloudAppState();
}

class _WineCloudAppState extends State<WineCloudApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LaunchPage(),
    );
  }
}
