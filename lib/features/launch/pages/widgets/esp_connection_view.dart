import 'package:esp_smartconfig/esp_smartconfig.dart';
import 'package:flutter/material.dart';

class EspConnectionView extends StatefulWidget {
  final String wifiSsid;
  final String wifiBssid;
  final String? wifiPassword;

  const EspConnectionView({
    required this.wifiSsid,
    required this.wifiBssid,
    required this.wifiPassword,
    super.key,
  });

  @override
  State<EspConnectionView> createState() => _EspConnectionViewState();
}

class _EspConnectionViewState extends State<EspConnectionView> {
  final _provisioner = Provisioner.espTouch();
  late final ProvisioningRequest _request;
  ProvisioningResponse? _lastResponse;
  bool _timeout = false;

  @override
  void initState() {
    super.initState();
    _request = ProvisioningRequest.fromStrings(
      ssid: widget.wifiSsid,
      bssid: widget.wifiBssid,
      password: widget.wifiPassword,
    );

    _provisioner.listen(_onResponse);
    _startConnection();
  }

  @override
  Widget build(BuildContext context) {
    if (_timeout) return _TimeoutView(refreshCallback: _startConnection);
    if (_lastResponse == null) return const _LoadingView();

    return _ConnectedView(response: _lastResponse!);
  }

  Future<void> _startConnection() async {
    setState(() => _timeout = false);

    await _provisioner.start(_request);
    await Future.delayed(const Duration(seconds: 15), () {});

    if (_lastResponse == null) {
      setState(() => _timeout = true);
      _provisioner.stop();
    }
  }

  void _onResponse(ProvisioningResponse response) {
    setState(() => _lastResponse = response);
    _provisioner.stop();
  }

  @override
  void dispose() {
    _provisioner.stop();
    super.dispose();
  }
}

class _ConnectedView extends StatelessWidget {
  final ProvisioningResponse response;

  const _ConnectedView({required this.response});

  @override
  Widget build(BuildContext context) {
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
            Text(response.ipAddressText ?? 'null'),
          ],
        ),
        Row(
          children: [
            Text('BSSIP: ', style: Theme.of(context).textTheme.labelSmall),
            Text(response.bssidText),
          ],
        ),
      ],
    );
  }
}

class _TimeoutView extends StatelessWidget {
  final VoidCallback? refreshCallback;

  const _TimeoutView({required this.refreshCallback});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Доступных соединений не обнаружено.'),
        const SizedBox(height: 8),
        MaterialButton(
          onPressed: refreshCallback,
          child: const Text('Повторить'),
        ),
      ],
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator();
  }
}
