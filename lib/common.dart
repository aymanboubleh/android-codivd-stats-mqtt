import 'dart:collection';
import 'dart:core';

import 'package:flutter/cupertino.dart';

//enum SENSOR_TYPE {
//  ACCELEROMETER,
//  TEMPERATURE,
//  GYROSCOPE,
//  PROXIMITY,
//  HUMIDITY,
//  LINEAR_ACCELERATION,
//  MAGNETIC_FIELD,
//  STEP_DETECTOR,
//  LIGHT_SENSOR
//}
class SensorTypes{
  static const ACCELEROMETER = 1;
  static const PRESSURE = 6;
  static const PROXIMITY = 8;
  static const GYROSCOPE = 4;
  static const AMBIANT_TEMPERATURE = 13;
  static const TEMPERATURE = 7; //deprecated
  static const MAGNETIC_FIELD = 2;
  static const LIGHT_SENSOR = 5;
  static const LINEAR_ACCELERATION = 10;
  static const HUMIDITY = 12;
  static const STEP_DETECTOR = 18;
  static const ROTATION = 11;
}

int DEFAULT_PORT = 1883;
String DEFAULT_BROKER = 'mqtt.eclipse.org';
String DEFAULT_USERNAME = '';
String DEFAULT_PASSWORD = '';
String DEFAULT_CLIENT_CLASSIFIER = '';
Widget _centerMessage(message){
    return Center(
      child: Text(message.toString()),
    );
}

