import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

class HomeController extends ChangeNotifier {
  SerialPort? _serialPort;
  String _receivedData = '';

  String get receivedData => _receivedData;

  Future<void> connect(String portName, int baudRate) async {
    _serialPort = SerialPort(portName);

    if (_serialPort!.openReadWrite()) {
      _serialPort!.config.baudRate = baudRate;

      final reader = SerialPortReader(_serialPort!);
      reader.stream.listen((data) {
        _receivedData = String.fromCharCodes(data);
        notifyListeners(); // Notify UI to update
      });
    } else {
      throw Exception('Failed to open serial port');
    }
  }

  void disconnect() {
    _serialPort?.close();
    _serialPort = null;
    _receivedData = '';
    notifyListeners();
  }

  List<String> get availablePorts => SerialPort.availablePorts;
}
