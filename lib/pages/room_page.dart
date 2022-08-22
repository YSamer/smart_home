import 'dart:math';

import 'package:smart_home/components/colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';

class RoomPage extends StatefulWidget {
  final String myID;
  final String room;
  const RoomPage({Key? key, required this.myID, required this.room}) : super(key: key);

  @override
  State<RoomPage> createState() => _RoomPageState(myID, room);
}

class _RoomPageState extends State<RoomPage> {
  _RoomPageState(this.myID, this.room);
  String myID;
  String room;
  List<String> devicesList = <String>[];
  List<bool> controllers = <bool>[];

  late Map<String, dynamic> devices;
  late DatabaseReference ref;
  late DataSnapshot snapshot;
  late DataSnapshot devicesInfo;


  @override
  void initState() {
    super.initState();
    readData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  readData() async {
    ref = FirebaseDatabase.instance.ref();
    snapshot = await ref.child('/').get();
    setState(() {
      ref.onValue.listen((DatabaseEvent event) {
        devicesInfo = event.snapshot.child('devices/users/${myID}/rooms/${room}/devices');
        devices = devicesInfo.value as Map<String, dynamic>;
        devicesList = devices.keys.toList();
        controllers.clear();
        for (int i = 0; i < devicesList.length; i++) {
          var deviceValue = devicesInfo
              .child(devicesList[i])
              .value;
          if (deviceValue == "true") {
            controllers.add(true);
          } else {
            controllers.add(false);
          }
        }
        setState(() {
          controllers;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(
                    Icons.menu,
                    size: 30,
                    color: kGreenColor,
                  ),
                  Text(
                    room,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: kBgColor,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          color: kGreenColor,
                          blurRadius: 8,
                          offset: Offset(3, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.notifications_none,
                      color: kGreenColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  for(var item in devicesList) Card(
                    child: ListTile(
                      leading: const Icon(Icons.tips_and_updates, color: kGreenColor),
                      title: Text(item),
                      subtitle: Text(
                        'Room',
                        style: TextStyle(color: Colors.black.withOpacity(0.6)),
                      ),
                      trailing: Switch(
                        value: controllers[devicesList.indexOf(item)],
                        onChanged: (value) {
                          setState(() {
                            controllers[devicesList.indexOf(item)] = value;
                            ref.child('devices/users/${myID}/rooms/${room}/devices/${item}').set(value.toString());
                          });
                        },
                      ),
                    ),
                  )
                ],
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.devices_other, color: kGreenColor,),
                  title: const Text('Add Device/Sensor'),
                  subtitle: Text(
                    'Click to Add',
                    style: TextStyle(color: Colors.black.withOpacity(0.6)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }


}
