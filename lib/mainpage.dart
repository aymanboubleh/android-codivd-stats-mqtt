import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              child: Center(
                child: Text("Covid19"),
              ),
            ),
            ListTile(
              title: Text("COVID19 Stats"),
              onTap: () {
                print("Redirecting to COVID19 Stats");
                Navigator.of(context).pop();
                Navigator.pushNamed(context, "/");
                Navigator.pushNamed(context, "/stats");
              },
            ),
            Divider(
              color: Colors.blueAccent,
            ),
            ListTile(
              title: Text("MQTT Publisher"),
              onTap: () {
                print("Redirecting to MQTT Publisher");
                Navigator.of(context).pop();
                Navigator.pushNamed(context, "/");
                Navigator.pushNamed(context, "/mqtt");
              },
            )
          ],
        ),
      ),
    );
  }
}
