import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:sensors/sensors.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'message.dart';
import 'package:proximity_plugin/proximity_plugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

enum SENSOR_TYPE {
  ACCELEROMETER,
  TEMPERATURE,
  GYROSCOPE,
  PROXIMITY,
  HUMIDITY,
}

class _MyAppState extends State<MyApp> {
  PageController _pageController;
  int _page = 0;
  String titleBar = 'MQTT';
  String broker = 'mqtt.eclipse.org';
  int port = 1883;
  String username = '';
  String passwd = '';
  String clientIdentifier = '';
  List<dynamic> sensorsList = [
    {
      '_index': 0,
      '_name': 'accelerometer1',
      '_type': SENSOR_TYPE.ACCELEROMETER,
      '_qosValue': 2,
      '_topic': 'Home/BedRoom/DHT1/Accelerometer',
      '_timer': 1,
      '_active': false,
      '_exist': true,
      '_data': null,
      '_fct': null,
      '_retain': false,
    },
    {
      '_index': 1,
      '_name': 'Gyroscope1',
      '_type': SENSOR_TYPE.GYROSCOPE,
      '_qosValue': 2,
      '_topic': 'Home/BedRoom/DHT1/Gyroscope',
      '_timer': 1,
      '_active': false,
      '_exist': true,
      '_data': null,
      '_fct': null,
      '_retain': false,
    },
    {
      '_index': 2,
      '_name': 'Proximity1',
      '_type': SENSOR_TYPE.PROXIMITY,
      '_qosValue': 2,
      '_topic': 'Home/BedRoom/DHT1/Proximity',
      '_timer': 1,
      '_active': false,
      '_exist': true,
      '_data': null,
      '_fct': null,
      '_retain': false,
    },
  ];
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

    sensorEvents();
    return MaterialApp(
      home: Scaffold(
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
              port = 1883;
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

  void updateSensorIDs() {
    sensorsList.forEach((element) {
      element['_name'] = clientIdentifier + element['_name'];
    });
  }

  Column _buildSensorsPage() {
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
    return sensorsList
        .map((sensor) => Card(
              child: Column(
                children: <Widget>[
                  Text(
                    sensor['_name'],
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontSize: 10),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(15, 2, 15, 2),
                    child: TextField(
                      onChanged: (value) {
                        sensorsList[sensor['_index']]['_topic'] = value;
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
                        try{
                        if (int.parse(value) < 0) return;

                        }catch(e){
                            value = '1';
                        }

                        sensorsList[sensor['_index']]['_timer'] = value;
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
                              sensor['_retain'] = !sensor['_retain'];
                            });
                          },
                          color: !sensor['_retain']
                              ? null
                              : Colors.lightBlueAccent,
                        ),
                        RaisedButton(
                          color: sensor['_active'] ? Colors.lightGreen : null,
                          child: sensor['_active']
                              ? Text('Disable')
                              : Text('Enable'),
                          onPressed: () {
                            if (client == null) {
                              print("Client is NULL");
                              return;
                            }

                            setState(() {
                              int index = sensor['_index'];
                              print("OK");
                              if (sensor['_active'] == true) {
                                sensorsList[index]['_active'] = false;
                                (sensorsList[index]['_fct'] as Timer).cancel();
                                print("PRINT ---> Canceling sensor " +
                                    sensor["_name"]);
                                sensorsList[index]['_data'] = null;
                              } else {
                                print("PRINT ---> Activating sensor " +
                                    sensor["_name"]);
                                sensorsList[index]['_active'] = true;
                                var duration;
                                try {
                                  duration = Duration(
                                      seconds: int.parse(sensorsList[index]
                                              ['_timer']
                                          .toString()));
                                } catch (_) {
                                  duration = Duration(seconds: 1);
                                }
                                sensorsList[index]['_fct'] =
                                    new Timer.periodic(duration, (Timer t) {
                                  if (sensorsList[index]['_data'] != null &&
                                      sensorsList[index]['_topic'] != null)
                                    sensorPublish(sensorsList[index]);
                                });
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

  void sensorEvents() {
    sensorsList.forEach((element) {
      if (!element['_exist']) return;
      switch (element['_type']) {
        case SENSOR_TYPE.ACCELEROMETER:
          accelerometerEvents.listen((AccelerometerEvent event) {
            element['_data'] = handleData(element['_type'], event);
          });
          break;
        case SENSOR_TYPE.PROXIMITY:
          print("PROXIMITY SENSOR EVENT");
          proximityEvents.listen((ProximityEvent event) {
//            print("------------PROXIMITY EVENT--------");
//            print(event);
            element['_data'] = handleData(element['_type'], event);
          });

          break;
        case SENSOR_TYPE.GYROSCOPE:
          accelerometerEvents.listen((AccelerometerEvent event) {
            element['_data'] = handleData(element['_type'], event);
          });
          break;

        default:
      }
    });
  }

  void sensorPublish(sensor) {
    if (sensor['_data'] == null) return;
    if (client == null) return;
    if (client.connectionStatus.state != MqttConnectionState.connected) return;

    final mqtt.MqttClientPayloadBuilder builder =
        mqtt.MqttClientPayloadBuilder();
    var data = sensor['_data'];
    data['SENSOR_ID'] = clientIdentifier + '_' + sensor['_name'];
    builder.addString(json.encode(sensor['_data']));
    print(json.encode(sensor['_data']));
    print(sensor['_topic']);
    client.publishMessage(
      sensor['_topic'],
      mqtt.MqttQos.values[sensor['_qosValue']],
      builder.payload,
      retain: sensor['_retain'],
    );

    setState(() {
      messages.add(Message(
        topic: sensor['_topic'],
        message: data.toString(),
        qos: mqtt.MqttQos.values[sensor['_qosValue']],
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

  dynamic handleData(SENSOR_TYPE sensorType, event) {
    var data = {};
    switch (sensorType) {
      case SENSOR_TYPE.ACCELEROMETER:
        event = event as AccelerometerEvent;
        data = {'x': event.x, 'y': event.x, 'z': event.z};
        break;
      case SENSOR_TYPE.GYROSCOPE:
        data = {'x': event.x, 'y': event.x, 'z': event.z};
        break;
      case SENSOR_TYPE.PROXIMITY:
        event = event as ProximityEvent;
        data = {'triggered': event.x == "Yes"};
        break;
      case SENSOR_TYPE.TEMPERATURE:
        // TODO: Handle this case.
        break;
      case SENSOR_TYPE.HUMIDITY:
        // TODO: Handle this case.
        break;
    }
    String date = new DateTime.now().toString();
    data['Date'] = date.substring(0, date.indexOf("."));
    return data;
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
    _onDisconnected();
  }

  void _onDisconnected() {
    setState(() {
      connectionState = MqttConnectionState.disconnected;
    });
    print('MQTT client disconnected');
  }

  Wrap _buildQosChoiceChips(sensor) {
    return Wrap(
      spacing: 4.0,
      children: List<Widget>.generate(
        3,
        (int index) {
          int sensor_index = sensor['_index'];
          return ChoiceChip(
            label: Text('QoS level $index'),
            selected: sensorsList[sensor_index]['_qosValue'] == index,
            onSelected: (bool selected) {
              setState(() {
                sensorsList[sensor_index]['_qosValue'] =
                    selected ? index : null;
              });
            },
          );
        },
      ).toList(),
    );
  }
}
