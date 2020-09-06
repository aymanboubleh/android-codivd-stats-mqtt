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
class MqttPublisher extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MqttPublisher> {
  PageController _pageController;
  int _page = 0;
  String titleBar = 'MQTT';
  String broker = DEFAULT_BROKER;
  int port = DEFAULT_PORT;
  String username = DEFAULT_USERNAME;
  String passwd = DEFAULT_PASSWORD;
  String clientIdentifier = DEFAULT_CLIENT_CLASSIFIER;
  bool sensorsListGenerated = false;
  List<dynamic> sensorsList2 = [
    {
      '_index': 0,
      '_name': 'accelerometer1',
      '_type': SensorTypes.ACCELEROMETER,
      '_qosValue': 2,
      '_topic': 'Home/BedRoom/DHT1/Accelerometer',
      '_timer': 2,
      '_delay': Sensors.SENSOR_DELAY_UI,
      '_active': false,
      '_exist': true,
      '_data': null,
      '_fct': null,
      '_retain': false,
      '_subscription': null,
    },
    {
      '_index': 1,
      '_name': 'Gyroscope1',
      '_type': SensorTypes.GYROSCOPE,
      '_qosValue': 2,
      '_topic': 'Home/BedRoom/DHT1/Gyroscope',
      '_timer': 2,
      '_delay': Sensors.SENSOR_DELAY_UI,
      '_active': false,
      '_exist': true,
      '_data': null,
      '_fct': null,
      '_retain': false,
      '_subscription': null,
    },
    {
      '_index': 2,
      '_name': 'Proximity1',
      '_type': SensorTypes.PROXIMITY,
      '_qosValue': 2,
      '_topic': 'Home/BedRoom/DHT1/Proximity',
      '_timer': 2,
      '_delay': Sensors.SENSOR_DELAY_UI,
      '_active': false,
      '_exist': true,
      '_data': null,
      '_fct': null,
      '_retain': false,
      '_subscription': null,
    },
    {
      '_index': 3,
      '_name': 'Light1',
      '_type': SensorTypes.LIGHT_SENSOR,
      '_qosValue': 2,
      '_topic': 'Home/BedRoom/DHT1/Light',
      '_timer': 2,
      '_delay': Sensors.SENSOR_DELAY_UI,
      '_active': false,
      '_exist': true,
      '_data': null,
      '_fct': null,
      '_retain': false,
      '_subscription': null,
    },
  ];
  List<SensorData> sensorsList = <SensorData>[];
  mqtt.MqttClient client;
  mqtt.MqttConnectionState connectionState = MqttConnectionState.disconnected;

  TextEditingController brokerController = TextEditingController();
  TextEditingController portController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwdController = TextEditingController();
  TextEditingController identifierController = TextEditingController();

  TextEditingController topicController = TextEditingController();

  List<Message> messages = <Message>[];
  ScrollController messageController = ScrollController();

  @override
  Widget build(BuildContext context) {
    IconData connectionStateIcon;
    switch (connectionState) {
      case mqtt.MqttConnectionState.connected:
        connectionStateIcon = Icons.cloud_done;
        break;
      case mqtt.MqttConnectionState.disconnected:
        connectionStateIcon = Icons.cloud_off;
        break;
      case mqtt.MqttConnectionState.connecting:
        connectionStateIcon = Icons.cloud_upload;
        break;
      case mqtt.MqttConnectionState.disconnecting:
        connectionStateIcon = Icons.cloud_download;
        break;
      case mqtt.MqttConnectionState.faulted:
        connectionStateIcon = Icons.error;
        break;
      default:
        connectionStateIcon = Icons.cloud_off;
    }
    void navigationTapped(int page) {
      _pageController.animateToPage(page,
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    }

    void onPageChanged(int page) {
      setState(() {
        this._page = page;
      });
    }

//    sensorEvents();
    return MaterialApp(

      home: Scaffold(
        drawer: MainDrawer(),
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(titleBar),
              SizedBox(
                width: 8.0,
              ),
              Icon(connectionStateIcon),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.white70,
          backgroundColor: Colors.blueAccent,
          onTap: navigationTapped,
          currentIndex: _page,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.cloud),
              title: Text('Broker'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message),
              title: Text('Sensors'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message),
              title: Text('Logs'),
            ),
          ],
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: onPageChanged,
          children: <Widget>[
            _buildBrokerPage(connectionStateIcon),
            _buildSensorsPage(),
            _buildMessagesPage(),
          ],
        ),
      ),
    );
  }

  Column _buildBrokerPage(IconData connectionStateIcon) {
    return Column(
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              //Input Broker
//              width: 200.0,
              padding: EdgeInsets.fromLTRB(15, 2, 15, 2),
              child: TextField(
                controller: brokerController,
                decoration: InputDecoration(hintText: 'Input broker'),
              ),
            ),
            Container(
              //Input Port
//              width: 200.0,
              padding: EdgeInsets.fromLTRB(15, 2, 15, 2),
              child: TextField(
                controller: portController,
                decoration: InputDecoration(hintText: 'Port(default 1883)'),
              ),
            ),
            Container(
              //Username
//              width: 200.0,
              padding: EdgeInsets.fromLTRB(15, 2, 15, 2),
              child: TextField(
                controller: usernameController,
                decoration: InputDecoration(hintText: 'Username(optional)'),
              ),
            ),
            Container(
              //Passwd
//              width: 200.0,
              padding: EdgeInsets.fromLTRB(15, 2, 15, 2),
              child: TextField(
                controller: passwdController,
                decoration: InputDecoration(hintText: 'Passwod(optional)'),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(15, 2, 15, 2),
              child: TextField(
                controller: identifierController,
                decoration: InputDecoration(hintText: 'Client Identifier'),
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              broker + ':' + port.toString(),
              style: TextStyle(fontSize: 24.0),
            ),
            SizedBox(width: 8.0),
            Icon(connectionStateIcon),
          ],
        ),
        SizedBox(height: 8.0),
        RaisedButton(
          child: Text(connectionState == mqtt.MqttConnectionState.connected
              ? 'Disconnect'
              : 'Connect'),
          onPressed: () {
            if (brokerController.value.text.isNotEmpty) {
              broker = brokerController.value.text;
            }

            port = int.tryParse(portController.value.text);
            if (port == null) {
              port = DEFAULT_PORT;
            }
            if (usernameController.value.text.isNotEmpty) {
              username = usernameController.value.text;
            }
            if (passwdController.value.text.isNotEmpty) {
              passwd = passwdController.value.text;
            }
            if (identifierController.value.text.isEmpty) {
              clientIdentifier =
                  'client_' + new Random().nextInt(1000).toString();
            }
            if (client != null &&
                client.connectionStatus.state ==
                    mqtt.MqttConnectionState.connected) {
              _disconnect();
            } else {
              _connect();
            }
          },
        ),
      ],
    );
  }

  Column _buildMessagesPage() {
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            controller: messageController,
            children: _buildMessageList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RaisedButton(
            child: Text('Clear'),
            onPressed: () {
              setState(() {
                messages.clear();
              });
            },
          ),
        )
      ],
    );
  }

  Widget _buildSensorsPage() {
//    if(client == null || client.connectionStatus.state != MqttConnectionState.connected)
//      return Center(
//        child:Text(
//                "Please connect to a MQTT Broker first",
//                style: TextStyle(color: Colors.redAccent),
//              ),
//      );
  if(!sensorsListGenerated)
createSensors(clientIdentifier);
 return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: _buildSensorsList(),
          ),
        ),
      ],
    );


  }

  @override
  void initState() {
    _pageController = PageController();
    super.initState();
  }

  List<Widget> _buildMessageList() {
    return messages
        .map((Message message) => Card(
              color: message.type == MESSAGE_TYPE.SENT
                  ? Colors.greenAccent
                  : Colors.lightGreen,
              child: ListTile(
                trailing: CircleAvatar(
                    radius: 14.0,
                    backgroundColor: Theme.of(context).accentColor,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'QoS',
                          style: TextStyle(fontSize: 8.0),
                        ),
                        Text(
                          message.qos.index.toString(),
                          style: TextStyle(fontSize: 8.0),
                        ),
                      ],
                    )),
                title: Text(message.topic),
                subtitle: Text(message.message),
                dense: true,
              ),
            ))
        .toList();
  }

  List<Widget> _buildSensorsList() {
    if(sensorsList.length < 1) {print('NULL SENSORSLIST') ;return [
      new Center(child: Text("Loading?"),)
    ].toList();}
    return sensorsList
        .map((SensorData sensor) => Card(
              child: Column(
                children: <Widget>[
                  Text(
                    sensor.name,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontSize: 10),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(15, 2, 15, 2),
                    child: TextField(
                      onChanged: (value) {
                        sensor.topic = value;
                      },
                      decoration: InputDecoration(hintText: "Topic"),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(15, 2, 15, 2),
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          hintText: "Seconds between publishing(default 1)"),
                      onChanged: (value) {
                        try {
                          if (int.parse(value) < 0) return;
                        } catch (e) {
                          value = '2';
                        }

                        sensor.timer_duration = int.parse(value);
                      },
                    ),
                  ),
                  _buildQosChoiceChips(sensor),
                  Container(
//                    padding: EdgeInsets.fromLTRB(15, 2, 15, 2),
                    child: Wrap(
                      spacing: 4.0,
                      children: <Widget>[
                        RaisedButton(
                          child: Text("retain"),
                          onPressed: () {
                            setState(() {
                              sensor.retain = !sensor.retain;
                            });
                          },
                          color: !sensor.retain ? null : Colors.lightBlueAccent,
                        ),
                        RaisedButton(
                          color: sensor.isActive ? Colors.lightGreen : null,
                          child: sensor.isActive
                              ? Text('Disable')
                              : Text('Enable'),
                          onPressed: () {
//                            if (client == null) {
//                              print("Client is NULL");
//                              return;
//                            }

                            setState(() {
                              if (sensor.isEnabled()) {
                                sensor.disable();
                                print('SENSOR DISACTIVATED');
                                print(sensor);
                                sensor.cancelSubscriptiont();
                                sensor.periodic_timer?.cancel();
                                print("PRINT ---> Canceling sensor " +
                                    sensor.name);
                                sensor.data = null;
                              } else {
                                print('SENSOR ACTIVATED');
                                print(sensor);
                                sensor.enable();
                                sensor.subscribe();
                                print("PRINT ---> Activating sensor " +
                                    sensor.name);
                                var duration;
                                try {
                                  duration =
                                      Duration(seconds: sensor.timer_duration);
                                } catch (_) {
                                  duration = Duration(seconds: 1);
                                }
//                                sensor.periodic_timer =
//                                    Timer.periodic(duration, (Timer t) {
//                                  if (sensor.data != null &&
//                                      sensor.topic != null)
//                                    sensorPublish(sensor);
//                                });
                              }
                            });
                          },
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ))
        .toList()
        .reversed
        .toList();
  }





  void sensorPublish(SensorData sensor) {
    if (sensor.data == null) return;
    if (client == null) return;
    if (client.connectionStatus.state != MqttConnectionState.connected) return;

    final mqtt.MqttClientPayloadBuilder builder =
        mqtt.MqttClientPayloadBuilder();
    var data = sensor.data;
    data['SENSOR_ID'] = sensor.name;
    builder.addString(json.encode(sensor.data));
    print(json.encode(sensor.data));
    print(sensor.topic);
    client.publishMessage(
      sensor.topic,
      mqtt.MqttQos.values[sensor.qosValue],
      builder.payload,
      retain: sensor.retain,
    );

    setState(() {
      messages.add(Message(
        topic: sensor.topic,
        message: data.toString(),
        qos: mqtt.MqttQos.values[sensor.qosValue],
      ));
      try {
        messageController.animateTo(
          0.0,
          duration: Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      } catch (_) {}
    });
  }

//
  void _connect() async {
    client = new MqttClient(broker, "");
    client.keepAlivePeriod = 20;
    client.port = port;
    client.onDisconnected = _onDisconnected;
    final MqttConnectMessage connMess = new MqttConnectMessage()
        .withClientIdentifier(clientIdentifier)
        .keepAliveFor(client.keepAlivePeriod)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    print("->Mosquitto client connecting....");
    client.connectionMessage = connMess;

    try {
      await client.connect(username, passwd);
    } catch (e) {
      print("->client exception - $e");
      client.disconnect();
    }

    if (client.connectionStatus.state == mqtt.MqttConnectionState.connected) {
      print('MQTT client connected');
      setState(() {
        connectionState = client.connectionStatus.state;
      });
    } else {
      print('ERROR: MQTT client connection failed - '
          'disconnecting, state is ${client.connectionStatus.state}');
      _disconnect();
    }
  }

  void _disconnect() {
    client.disconnect();
    sensorsList = null;
    _onDisconnected();
  }

  void _onDisconnected() {
    setState(() {
      connectionState = MqttConnectionState.disconnected;
    });
    print('MQTT client disconnected');
  }

  Wrap _buildQosChoiceChips(SensorData sensor) {
    return Wrap(
      spacing: 4.0,
      children: List<Widget>.generate(
        3,
        (int index) {
          return ChoiceChip(
            label: Text('QoS level $index'),
            selected: sensor.qosValue == index,
            onSelected: (bool selected) {
              setState(() {
                sensor.qosValue = selected ? index : null;
              });
            },
          );
        },
      ).toList(),
    );
  }
  createSensors(String clientID) async{
    print('Cllaed');
  List<SensorData> list =  [
//    new SensorData(clientID + "_" + "Accelerometer", SensorTypes.ACCELEROMETER,
//        "/Home/BedRoom/DHT1/Accelerometer"),
//    new SensorData(clientID + "_" + "Linear_Acceleration", SensorTypes.LINEAR_ACCELERATION,
//        "/Home/BedRoom/DHT1/LinearAcceleration"),
//    new SensorData(clientID + "_" + "Light", SensorTypes.LIGHT_SENSOR,
//        "/Home/BedRoom/DHT1/LightSensor"),
//      new SensorData(clientID + "_" + "Magnetic_Field", SensorTypes.MAGNETIC_FIELD,
//        "/Home/BedRoom/DHT1/MagneticField"),
//          new SensorData(clientID + "_" + "Humidity", SensorTypes.HUMIDITY,
//        "/Home/BedRoom/DHT1/Humidity"),
//          new SensorData(clientID + "_" + "Temperature", SensorTypes.TEMPERATURE,
//        "/Home/BedRoom/DHT1/Temperature"),
//              new SensorData(clientID + "_" + "Pressure", SensorTypes.PRESSURE,
//        "/Home/BedRoom/DHT1/Pressure"),
//              new SensorData(clientID + "_" + "Ambiant_Temperature", SensorTypes.AMBIANT_TEMPERATURE,
//        "/Home/BedRoom/DHT1/Ambiant_Temperature"),
//    new SensorData(clientID + "_" + "Gyroscope",SensorTypes.GYROSCOPE,
//        "/Home/BedRoom/DHT1/Gyroscope"),
    new SensorData(clientID + "_" + "Proximity",SensorTypes.PROXIMITY,
        "/Home/BedRoom/DHT1/Proximity"),
  ].toList();

//  map((SensorData sensor) async {
//
//    bool isAvailable = await SensorManager().isSensorAvailable(sensor.type);
//            if(isAvailable){
//              print('SENSOR' + sensor.type.toString() + 'is Available');
//              setState(() {
//              sensorsList.add(sensor);
//
//              });
//        }
//        print('SENSOR' + sensor.type.toString() + 'is NOT Available');
//  });
//
    list.forEach((element) async{
              bool isAvailable = await SensorManager().isSensorAvailable(element.type);
            if(isAvailable) {
              print('SENSOR' + element.type.toString() + 'is Available');
              setState(() {
                sensorsList.add(element);
              });
            }
              });
    sensorsListGenerated = true;


}

}
