import 'package:mqtt_client/mqtt_client.dart' as mqtt;
enum MESSAGE_TYPE{
  SENT,
  RECEIVED
}
class Message {
  String topic;
  String message;
  mqtt.MqttQos qos;
  MESSAGE_TYPE type = MESSAGE_TYPE.SENT;  //False ==> sent
          //True ==> received
  Message({this.topic, this.message, this.qos});
}
