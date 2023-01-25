import 'package:esp_smartconfig/esp_smartconfig.dart';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';

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
    if (!_hasWifiData) return const CircularProgressIndicator();

    return _EspConnectionView(
      wifiSsid: _wifiSsid!,
      wifiBssid: _wifiBssid!,
      wifiPassword: _wifiPassword,
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
        builder: (context) => _WifiPasswordDialog(wifiSsid: _wifiSsid),
      );
    }

    setState(() {
      _wifiSsid = networkData.first;
      _wifiBssid = networkData.last;
      _wifiPassword = wifiPassword;
    });
  }
}

class _WifiPasswordDialog extends StatelessWidget {
  final String? wifiSsid;
  final TextEditingController _controller;

  _WifiPasswordDialog({required this.wifiSsid}) : _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Введите пароль от Wi-Fi'),
      content: Column(
        children: [
          if (wifiSsid != null) ...[
            Text(wifiSsid!),
            const SizedBox(height: 8),
          ],
          TextField(
            controller: _controller,
            autofocus: true,
            obscureText: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Подтвердить'),
        )
      ],
    );
  }
}

class _EspConnectionView extends StatefulWidget {
  final String wifiSsid;
  final String wifiBssid;
  final String? wifiPassword;

  const _EspConnectionView({
    required this.wifiSsid,
    required this.wifiBssid,
    required this.wifiPassword,
  });

  @override
  State<_EspConnectionView> createState() => _EspConnectionViewState();
}

class _EspConnectionViewState extends State<_EspConnectionView> {
  final _provisioner = Provisioner.espTouch();
  ProvisioningResponse? _lastResponse;

  @override
  void initState() {
    super.initState();
    final request = ProvisioningRequest.fromStrings(
      ssid: widget.wifiSsid,
      bssid: widget.wifiBssid,
      password: widget.wifiPassword,
    );

    _provisioner
      ..listen(_onResponse)
      ..start(request);
  }

  @override
  Widget build(BuildContext context) {
    if (_lastResponse == null) return const CircularProgressIndicator();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Девайс успешно подключен!',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text('IP address: ', style: Theme.of(context).textTheme.labelSmall),
            Text(_lastResponse!.ipAddressText ?? 'null'),
          ],
        ),
        Row(
          children: [
            Text('BSSIP: ', style: Theme.of(context).textTheme.labelSmall),
            Text(_lastResponse!.bssidText),
          ],
        ),
      ],
    );
  }

  void _onResponse(ProvisioningResponse response) => setState(() => _lastResponse = response);

  @override
  void dispose() {
    _provisioner.stop();
    super.dispose();
  }
}
