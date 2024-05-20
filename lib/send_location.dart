import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:geolocator/geolocator.dart';

/*傳送學生定位給老師*/
void main() {
  runApp(MyApp());
}

class MQTTManager {
  late MqttServerClient client;
  Timer? _timer;
  final String _topic;

  MQTTManager(String studentID) : _topic = 'location' + studentID {
    _connectToMQTT();
  }

  void _connectToMQTT() {
    client = MqttServerClient("test.mosquitto.org",
        "mqtt_explorer_" + DateTime.now().millisecondsSinceEpoch.toString());
    client.onConnected = _onConnected;
    _connect();
  }

  void _onConnected() {
    print('Connected to MQTT broker');
    _startLocationUpdates();
  }

  Future<void> _connect() async {
    try {
      await client.connect();
    } catch (e) {
      print('Error connecting to MQTT broker: $e');
    }
  }

  Future<void> _sendLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      String locationMessage =
          'Latitude: ${position.latitude}, Longitude: ${position.longitude}';
      _publishMessage(_topic, locationMessage);
      print('Sent location: $locationMessage');
    } catch (e) {
      print('Failed to get location: $e');
    }
  }

  void _publishMessage(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
    print('Published message: $message to topic: $topic');
  }

  void _startLocationUpdates() {
    _timer = Timer.periodic(Duration(seconds: 20), (timer) {
      _sendLocation();
    });
  }

  void dispose() {
    _timer?.cancel();
    client.disconnect();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MQTT Location Sender',
      home: MQTTScreen(),
    );
  }
}

class MQTTScreen extends StatefulWidget {
  @override
  _MQTTScreenState createState() => _MQTTScreenState();
}

class _MQTTScreenState extends State<MQTTScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MQTT Location Sender'),
      ),
      body: Center(
        child: Text('Sending location data to topic: '),
      ),
    );
  }
}
