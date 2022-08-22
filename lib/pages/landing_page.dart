import 'dart:async';

import 'package:smart_home/components/colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:smart_home/pages/room_page.dart';

class LandingPage extends StatefulWidget {
  final String myID;
  final String myName;
  const LandingPage({Key? key, required this.myID, required this.myName}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState(myID, myName);
}

class _LandingPageState extends State<LandingPage> {
  _LandingPageState(this.myID, this.myName);
  String myID;
  String myName;

  List<String> roomsList = <String>[];

  late Map<String, dynamic> rooms;
  late DatabaseReference ref;
  late DataSnapshot snapshot;
  late DataSnapshot roomsInfo;
  late DataSnapshot states;

  String date = '2022/07/15';
  String time = '00:00';

  String temp = '0.0';
  String hum = '0.0';
  String rain = 'false';
  String gas = 'false';

  @override
  void initState() {
    super.initState();
    readData();
    Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime());
  }

  void _getTime() {
    DateTime now = DateTime.now();
    setState(() {
      date = "${now.year.toString()}/${now.month.toString().padLeft(2,'0')}/${now.day.toString().padLeft(2,'0')}";
      time = "${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}";
    });
  }

  readData() async {
    ref = FirebaseDatabase.instance.ref();
    snapshot = await ref.child('/').get();
    setState(() {
      ref.onValue.listen((DatabaseEvent event) {
        roomsInfo = event.snapshot.child('devices/users/$myID/rooms');
        states = event.snapshot.child('devices/users/$myID/states');
        rooms = roomsInfo.value as Map<String, dynamic>;
        roomsList = rooms.keys.toList();
        setState(() {
          temp = states.child('temp').value.toString();
          hum = states.child('hum').value.toString();
          rain = states.child('rain').value.toString();
          gas = states.child('gas').value.toString();
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
                  const Text(
                    'Home',
                    style: TextStyle(
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: SizedBox(
                      height: 100,
                      width: 100,
                      child: CircleAvatar(
                        backgroundColor: kGreenColor,
                        child: Text(
                          myName[0],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                  SizedBox(
                    width: size.width - 225,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          date,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          time,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "Good Morning,\n$myName",
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 27,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              const Divider(),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '$temp°',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.deepPurpleAccent,
                          ),
                        ),
                        const Text(
                          'TEMPERATURE',
                          style: TextStyle(fontSize: 16, color: kGreenColor),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '$hum%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.deepPurpleAccent,
                          ),
                        ),
                        const Text(
                          'HUMIDITY',
                          style: TextStyle(fontSize: 16, color: kGreenColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              const Divider(),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                          rain=='false' ? 'Doesn\'t Rain' : 'Is Raining',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.deepPurpleAccent,
                          ),
                        ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        gas=='false' ? 'Gas Protected' : 'Gas Leaking',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.deepPurpleAccent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              const Divider(),
              const SizedBox(height: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  for(var item in roomsList) Card(
                    child: ListTile(
                      onTap: ()=>{
                        Navigator.push(context, CupertinoPageRoute(builder: (context) => RoomPage(myID: myID, room: item)))
                      },
                      leading: const Icon(Icons.meeting_room, color: kGreenColor),
                      title: Text(item),
                      subtitle: Text(
                        'Room',
                        style: TextStyle(color: Colors.black.withOpacity(0.6)),
                      ),
                    ),
                  )
                ],
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.meeting_room, color: kGreenColor,),
                  title: const Text('Add Room/Department'),
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
