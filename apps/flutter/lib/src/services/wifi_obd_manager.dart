import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import '../models/obd_data.dart';
import 'data_provider.dart';

class WiFiOBDManager implements DataProvider {
  WiFiOBDManager({String host = '192.168.4.1', int port = 35000})
    : _host = host,
      _port = port;

  final _obdDataController = StreamController<OBDData>.broadcast();
  final _stateController = StreamController<ConnectionState>.broadcast();

  OBDData _currentData = const OBDData();
  ConnectionState _state = ConnectionState.disconnected;

  Socket? _socket;
  bool _shouldReconnect = false;
  Timer? _pollTimer;
  int _tickCount = 0;
  int _reconnectAttempts = 0;
  String _buffer = '';

  String _host;
  int _port;

  @override
  Stream<OBDData> get obdDataStream => _obdDataController.stream;

  @override
  Stream<ConnectionState> get connectionStateStream => _stateController.stream;

  @override
  OBDData get currentData => _currentData;

  @override
  ConnectionState get connectionState => _state;

  void updateEndpoint({required String host, required int port}) {
    _host = host;
    _port = port;
  }

  @override
  Future<void> start() async {
    _shouldReconnect = true;
    await _connect();
  }

  Future<void> _connect() async {
    await stop();
    _shouldReconnect = true;
    _setState(ConnectionState.connecting);

    try {
      final socket = await Socket.connect(
        _host,
        _port,
        timeout: const Duration(seconds: 5),
      );
      _socket = socket;
      _reconnectAttempts = 0;
      _startListening();
      await _runHandshake();
      _setState(ConnectionState.connected);
      _startPolling();
    } catch (_) {
      _setState(ConnectionState.error);
      _scheduleReconnect();
    }
  }

  void _startListening() {
    _socket?.listen(
      (raw) {
        _buffer += ascii.decode(raw, allowInvalid: true);
        _consumeFrames();
      },
      onError: (_) => _scheduleReconnect(),
      onDone: _scheduleReconnect,
      cancelOnError: true,
    );
  }

  Future<void> _runHandshake() async {
    _setState(ConnectionState.initializing);
    const commands = ['ATZ\r', 'ATE0\r', 'ATL1\r', 'ATSP0\r'];
    for (final command in commands) {
      _send(command);
      await Future<void>.delayed(const Duration(milliseconds: 400));
    }
  }

  void _startPolling() {
    _tickCount = 0;
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(milliseconds: 240), (_) {
      _send('010C\r');
      _send('010D\r');

      if (_tickCount % 3 == 0) {
        _send('0105\r');
        _send('0104\r');
        _send('0106\r');
        _send('0107\r');
        _send('010F\r');
        _send('0110\r');
        _send('0111\r');
      }
      _tickCount += 1;
    });
  }

  void _consumeFrames() {
    while (_buffer.contains('>')) {
      final index = _buffer.indexOf('>');
      final frame = _buffer.substring(0, index);
      _buffer = _buffer.substring(index + 1);
      _parseResponse(frame);
    }
  }

  void _parseResponse(String raw) {
    final lines = raw.replaceAll('\r', '\n').split('\n');
    var data = _currentData;

    for (final line in lines) {
      final cleaned = line.trim().replaceAll(' ', '').toUpperCase();
      if (!cleaned.startsWith('41') || cleaned.length < 4) continue;

      final pid = cleaned.substring(2, 4);
      final bytesHex = cleaned.substring(4);
      switch (pid) {
        case '0C':
          final a = _hexByte(bytesHex, 0);
          final b = _hexByte(bytesHex, 1);
          if (a != null && b != null) {
            data = data.copyWith(rpm: ((256 * a) + b) / 4.0);
          }
          break;
        case '0D':
          final a = _hexByte(bytesHex, 0);
          if (a != null) {
            data = data.copyWith(speed: a.toDouble());
          }
          break;
        case '05':
          final a = _hexByte(bytesHex, 0);
          if (a != null) {
            data = data.copyWith(coolantTemp: a - 40.0);
          }
          break;
        case '04':
          final a = _hexByte(bytesHex, 0);
          if (a != null) {
            data = data.copyWith(engineLoad: a * (100 / 255.0));
          }
          break;
        case '06':
          final a = _hexByte(bytesHex, 0);
          if (a != null) {
            data = data.copyWith(shortTermFuelTrim: (a - 128) * (100 / 128.0));
          }
          break;
        case '07':
          final a = _hexByte(bytesHex, 0);
          if (a != null) {
            data = data.copyWith(longTermFuelTrim: (a - 128) * (100 / 128.0));
          }
          break;
        case '0F':
          final a = _hexByte(bytesHex, 0);
          if (a != null) {
            data = data.copyWith(intakeTemp: a - 40.0);
          }
          break;
        case '10':
          final a = _hexByte(bytesHex, 0);
          final b = _hexByte(bytesHex, 1);
          if (a != null && b != null) {
            data = data.copyWith(mafRate: ((256 * a) + b) / 100.0);
          }
          break;
        case '11':
          final a = _hexByte(bytesHex, 0);
          if (a != null) {
            data = data.copyWith(throttlePosition: a * (100 / 255.0));
          }
          break;
      }
    }

    final speed = data.speed;
    final consumption = speed > 5
        ? ((data.mafRate * 3600) / (14.7 * 745.0 * speed) * 100).clamp(0, 40)
        : 0.0;
    _currentData = data.copyWith(fuelConsumptionRate: consumption.toDouble());
    _obdDataController.add(_currentData);
  }

  double? _hexByte(String hex, int index) {
    final start = index * 2;
    if (hex.length < start + 2) return null;
    return int.tryParse(hex.substring(start, start + 2), radix: 16)?.toDouble();
  }

  void _send(String command) {
    _socket?.add(ascii.encode(command));
  }

  void _scheduleReconnect() {
    if (!_shouldReconnect) return;
    _pollTimer?.cancel();
    _socket?.destroy();
    _socket = null;

    if (_reconnectAttempts >= 5) {
      _setState(ConnectionState.error);
      return;
    }
    _reconnectAttempts += 1;
    final delay = min(pow(2, _reconnectAttempts).toInt(), 30);
    _setState(ConnectionState.scanning);
    Future<void>.delayed(Duration(seconds: delay), () {
      if (_shouldReconnect) {
        _connect();
      }
    });
  }

  void _setState(ConnectionState state) {
    _state = state;
    _stateController.add(_state);
  }

  @override
  Future<void> stop() async {
    _pollTimer?.cancel();
    _pollTimer = null;
    _socket?.destroy();
    _socket = null;
    _shouldReconnect = false;
    _setState(ConnectionState.disconnected);
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _socket?.destroy();
    _obdDataController.close();
    _stateController.close();
  }
}
