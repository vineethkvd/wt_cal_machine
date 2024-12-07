import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';

import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:flutter/material.dart';

class HomeController with ChangeNotifier {
  SerialPort? _serialPort; // Current active serial port
  String _receivedData = ''; // Parsed weight data
  String _rawDataBuffer = ''; // Buffer for raw incoming data

  String get receivedData => _receivedData;

  /// Connect to a serial port with the specified [portName] and [baudRate].
  Future<void> connect(String portName, int baudRate) async {
    // Disconnect any existing connection
    disconnect();

    _serialPort = SerialPort(portName);

    // Try to open the serial port for read/write
    if (_serialPort!.openReadWrite()) {
      _serialPort!.config.baudRate = baudRate;

      final reader = SerialPortReader(_serialPort!);

      // Listen to the data stream from the serial port
      reader.stream.listen(
            (data) {
          _handleIncomingData(data as Uint8List);
        },
        onError: (error) {
          print('Serial port error: $error');
          disconnect(); // Disconnect on error
        },
        cancelOnError: true,
      );
    } else {
      throw Exception('Failed to open serial port');
    }
  }

  /// Disconnects from the serial port.
  void disconnect() {
    _serialPort?.close();
    _serialPort = null;
    _receivedData = '';
    _rawDataBuffer = '';
    notifyListeners();
  }

  /// Handles raw incoming data from the serial port.
  void _handleIncomingData(Uint8List data) {
    // Convert raw bytes to a string and append to the buffer
    _rawDataBuffer += String.fromCharCodes(data as Iterable<int>);

    // Process messages based on a delimiter (e.g., '\n')
    if (_rawDataBuffer.contains('\n')) {
      final messages = _rawDataBuffer.split('\n');
      for (var message in messages) {
        if (message.isNotEmpty) {
          _receivedData = _parseWeight(message.trim());
          notifyListeners(); // Notify the UI of updated data
        }
      }

      // Retain any unprocessed data in the buffer
      _rawDataBuffer = _rawDataBuffer.endsWith('\n') ? '' : messages.last;
    }
  }

  /// Parses the weight value from raw data.
  String _parseWeight(String rawData) {
    // Extract numeric data (e.g., weight) from the raw string
    final weightMatch = RegExp(r'[\d.]+').firstMatch(rawData);
    return weightMatch != null ? weightMatch.group(0)! : 'Invalid Data';
  }

  /// Returns a list of available serial ports.
  List<String> get availablePorts => SerialPort.availablePorts;
}
