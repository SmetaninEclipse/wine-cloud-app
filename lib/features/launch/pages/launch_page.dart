import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:wine_cloud_app/features/launch/pages/widgets/esp_connection_view.dart';
import 'package:wine_cloud_app/features/launch/pages/widgets/wifi_password_dialog.dart';

class LaunchPage extends StatefulWidget {
  const LaunchPage({super.key});

  @override
  State<LaunchPage> createState() => _LaunchPageState();
}

class _LaunchPageState extends State<LaunchPage> {
  final _network = NetworkInfo();
  String? _wifiSsid;
  String? _wifiBssid;
  String? _wifiPassword;

  @override
  void initState() {
    super.initState();
    _getWifiPassword();
  }

  bool get _hasWifiData {
    return _wifiSsid != null && _wifiBssid != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: _hasWifiData
              ? EspConnectionView(
                  wifiSsid: _wifiSsid!,
                  wifiBssid: _wifiBssid!,
                  wifiPassword: _wifiPassword,
                )
              : const CircularProgressIndicator(),
        ),
      ),
    );
  }

  Future<String?> _getWifiPassword() async {
    String? wifiPassword;
    final networkData = await Future.wait<String?>([
      _network.getWifiName(),
      _network.getWifiBSSID(),
    ]);

    if (mounted) {
      wifiPassword = await showDialog<String>(
        context: context,
        builder: (context) => WifiPasswordDialog(wifiSsid: _wifiSsid),
      );
    }

    setState(() {
      _wifiSsid = networkData.first;
      _wifiBssid = networkData.last;
      _wifiPassword = wifiPassword;
    });
  }
}
