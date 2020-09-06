import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_sensors/flutter_sensors.dart';
import 'package:light/light.dart';
import 'drawer.dart';
import 'mqtt-publisher.dart';
import 'stats.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'message.dart';
import 'package:proximity_plugin/proximity_plugin.dart';
import 'common.dart';
import 'SensorData.dart';

void main(){
  runApp(MaterialApp(
    home: Home(),
    routes: <String, WidgetBuilder>{
    '/mqtt':(BuildContext context)=> MqttPublisher(),
    '/stats':(BuildContext context)=> StatsPage(),
  }));
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      drawer: MainDrawer(),
      appBar: new AppBar(
        title: Center(
          child: Text("COVID-19"),
        ),
      ),
      body: Center(
        child: Text("Check drawer"),
      ),
    );
  }
}


