import 'dart:async';
import 'dart:convert';
import 'common.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sensors/flutter_sensors.dart';
import 'package:proximity_plugin/proximity_plugin.dart';
import 'package:light/light.dart';
//import 'package:enviro_sensors/enviro_sensors.dart';

class SensorData {
  static int count = 0;
  String name;
  int type;

  String topic;
  int timer_duration = 2;
  int qosValue = 2;
  Duration delay = Sensors.SENSOR_DELAY_NORMAL;
  bool isActive = false;
  bool streamOn = false;
  bool exists = true;
  dynamic data = null;
  Timer periodic_timer = null;
  bool retain = false;
  dynamic subscription = null;

  SensorData(String name, int type, String topic) {
    this.name = name;
    this.type = type;
    this.topic = topic;
    count++;
  }

  subscribe() async {
    if (streamOn) return;
    Stream<SensorEvent> stream;
//    if (isAvailable == false) return null;
    switch (type) {
      case SensorTypes.ACCELEROMETER:
        streamOn = true;
        stream = await SensorManager()
            .sensorUpdates(sensorId: Sensors.ACCELEROMETER, interval: delay);
        subscription = stream.listen((sensorEvent) {
          if (isActive) data = handleData(type, sensorEvent);
        });
        break;
      case SensorTypes.LINEAR_ACCELERATION:
        streamOn = true;
        stream = await SensorManager().sensorUpdates(
            sensorId: Sensors.LINEAR_ACCELERATION, interval: delay);
        subscription = stream.listen((sensorEvent) {
          if (isActive) data = handleData(type, sensorEvent);
        });
        break;
      case SensorTypes.ROTATION:
        streamOn = true;
        stream = await SensorManager()
            .sensorUpdates(sensorId: Sensors.ROTATION, interval: delay);
        subscription = stream.listen((sensorEvent) {
          if (isActive) data = handleData(type, sensorEvent);
        });
        break;
      case SensorTypes.MAGNETIC_FIELD:
        streamOn = true;
        stream = await SensorManager()
            .sensorUpdates(sensorId: Sensors.MAGNETIC_FIELD, interval: delay);
        subscription = stream.listen((sensorEvent) {
          if (isActive) data = handleData(type, sensorEvent);
        });
        break;
      case SensorTypes.STEP_DETECTOR:
        streamOn = true;
        stream = await SensorManager()
            .sensorUpdates(sensorId: Sensors.STEP_DETECTOR, interval: delay);
        subscription = stream.listen((sensorEvent) {
          if (isActive) data = handleData(type, sensorEvent);
        });
        break;
      case SensorTypes.GYROSCOPE:
        streamOn = true;
        stream = await SensorManager()
            .sensorUpdates(sensorId: Sensors.GYROSCOPE, interval: delay);
        subscription = stream.listen((sensorEvent) {
          if (isActive) data = handleData(type, sensorEvent);
        });
        break;
      case SensorTypes.PROXIMITY:
        streamOn = true;
        proximityEvents.listen((ProximityEvent sensorEvent) {
          if (isActive) data = handleData(type, sensorEvent);
        });
        subscription = null;
        break;
//      case SensorTypes.PRESSURE:
//        streamOn = true;
//        barometerEvents
//            .listen((sensorEvent) {
//          if (isActive) data = handleData(type, sensorEvent);
//        });
//        subscription = null;
//        break;
      case SensorTypes.HUMIDITY:
        streamOn = true;
//        humidityEvents
//            .listen((HumidityEvent sensorEvent) {
//          if (isActive) data = handleData(type, sensorEvent);
//        });
//        subscription = null;
                stream = await SensorManager()
            .sensorUpdates(sensorId: SensorTypes.HUMIDITY, interval: delay);
        subscription = stream.listen((sensorEvent) {
          if (isActive) data = handleData(type, sensorEvent);
        });
        break;
//      case SensorTypes.AMBIANT_TEMPERATURE:
//        streamOn = true;
//        subscription = ambientTempEvents
//            .listen((event) {
//          if (isActive) data = handleData(type, event);
//        });
//
//        subscription = null;
//        break;
      case SensorTypes.LIGHT_SENSOR:
        streamOn = true;
        Light light = new Light();

        try {
          subscription = light.lightSensorStream.listen((sensorEvent) {
            if (isActive) data = handleData(type, sensorEvent);
          });
        } on LightException catch (e) {
          print(e);
        }
        break;
      default:
    }
  }

  static dynamic handleData(int sensorType, event) {
    var data = {};
    switch (sensorType) {
      case SensorTypes.ACCELEROMETER:
//        event = event as AccelerometerEvent;
        print("handleData->ACCELEROMETER--------");
        print(json.encode(event.data));
//        data = {'x': event.x, 'y': event.x, 'z': event.z};
        break;
      case SensorTypes.GYROSCOPE:
        print("handleData->GYROSCOPE--------");
//        data = {'x': event.x, 'y': event.x, 'z': event.z};
        print(json.encode(event.data));
        break;
      case SensorTypes.PROXIMITY:
//        event = event as ProximityEvent;
        print("handleData->Proximity--------");
//        data = {'triggered': event.x == "Yes"};
        print(jsonEncode(event.x));
        break;
      case SensorTypes.TEMPERATURE:
      // TODO: Handle this case.
        print("handleData->TEMPERATURE SENSOR------");
        print(json.encode(event.data));
//        data = event;
        break;
      case SensorTypes.HUMIDITY:
      // TODO: Handle this case.
        print("handleData->HUMIDITY SENSOR------");
//        data = event;
        print(json.encode(event.data));
        break;
      case SensorTypes.LINEAR_ACCELERATION:
      // TODO: Handle this case.
        print("handleData->LINEAR_ACCELERATION SENSOR------");
//        data = event;
        print(json.encode(event.data));
        break;
      case SensorTypes.MAGNETIC_FIELD:
        print("handleData->MAGNETIC_FIELD----------");
//        data = event;
        print(json.encode(event.data));
        // TODO: Handle this case.
        break;
      case SensorTypes.STEP_DETECTOR:
      // TODO: Handle this case.
        print("handleData->LIGHT SENSOR------");
        print(json.encode(event.data));
//        data = event;
        break;
      case SensorTypes.LIGHT_SENSOR:
      // TODO: Handle this case.
        print("handleData->LIGHT SENSOR------");
//        data = event;
        print('LUX-->' + event.toString());
        break;
    }
    String date = new DateTime.now().toString();
    data['Date'] = date.substring(0, date.indexOf("."));
    return data;
  }

  @override
  String toString() {
    return 'SensorData$count{name: $name, type: $type, topic: $topic, timer_duration: $timer_duration, qosValue: $qosValue, delay: $delay, isActive: $isActive, exists: $exists, data: $data, periodic_timer: $periodic_timer, retain: $retain, subscription: $subscription}';
  }

  void enable() {
    isActive = true;
  }

  void disable() {
    isActive = false;
  }

  bool isEnabled() {
    return isActive;
  }

  void cancelSubscriptiont() {
    print('Canceling subscription...Needs to be fixed');
  }
}
