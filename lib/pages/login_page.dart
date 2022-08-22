import 'package:flutter/material.dart';
import 'package:smart_home/components/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:smart_home/pages/landing_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  bool _isObscure = true;
  bool _isPassTrue = true;
  bool _isEmailTrue = true;
  bool value = true;

  final passController = TextEditingController();
  final emailController = TextEditingController();
  late Map<String, dynamic> usersInfo;
  List usersEmails = [];
  List usersNums = [];
  List usersPass = [];
  List usersIDs = [];

  late String _myID;
  late String myEmail;
  late String myPass;
  late String myName;
  bool remembered = false;

  late DatabaseReference ref;
  late DataSnapshot snapshot;
  late DataSnapshot snapshotInfo;



  @override
  void dispose() {
    passController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    readData();
    share_pref();
  }
  readData() async {
    ref = FirebaseDatabase.instance.ref();
    snapshot = await ref.child('/').get();
    setState(() {
      snapshotInfo = snapshot.child('/users/');
      usersInfo = snapshotInfo.value as Map<String, dynamic>;
      usersNums = usersInfo.keys.toList();
      for (int i = 0; i < usersNums.length; i++) {
        usersEmails.add(snapshotInfo
            .child(usersNums[i] + '/email/')
            .value);
        usersPass.add(snapshotInfo
            .child(usersNums[i] + '/password/')
            .value);
      }
    });
  }

  share_pref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      remembered = prefs.getBool('remember')!;
      myEmail = prefs.getString('myEmail')!;
      myPass = prefs.getString('myPass')!;
      myName = prefs.getString('myName')!;
      _myID = prefs.getString('myID')!;

      if (remembered && myEmail.isNotEmpty && myPass.isNotEmpty &&
          _myID.isNotEmpty && _myID.length == 10) {
        Navigator.push(context,
            CupertinoPageRoute(builder: (context) => LandingPage(myID: _myID, myName: myName)));
      }
    });
  }


  void _onCheckedChanged() {
    setState(() {
      value = !value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  errorText: _isEmailTrue ? null : 'Invalid Email',
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: passController,
                obscureText: _isObscure,
                // initialValue: 'Smart2022',
                decoration: InputDecoration(
                    labelText: 'Password',
                    errorText: _isPassTrue ? null : 'Invalid Password',
                    suffixIcon: IconButton(
                        icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _isObscure = !_isObscure;
                          });
                        })),
              ),
              const SizedBox(height: 20),
              CheckboxListTile(
                title: const Text("Remember Me"),
                value: value,
                onChanged: (v) => _onCheckedChanged(),
              ),
              SizedBox(
                width: 175.0,
                height: 40.0,
                child: ElevatedButton(
                  onPressed: () async {
                    if (usersEmails.contains(emailController.text)) {
                      if(usersPass[usersEmails.indexOf(emailController.text)] == passController.text){
                        int index = usersEmails.indexOf(emailController.text);
                        _myID = snapshotInfo.child('${usersNums[index]}/ID/').value as String;
                        myName = snapshotInfo.child('${usersNums[index]}/name/').value as String;
                        //Set Preferences
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.setString('myEmail', emailController.text);
                        await prefs.setString('myPass', passController.text);
                        await prefs.setString('myID', _myID);
                        await prefs.setString('myName', myName);
                        await prefs.setBool('remember', value);

                        setState(() {
                          _isEmailTrue = true;
                          _isPassTrue = true;
                        });
                        emailController.text = '';
                        passController.text = '';
                        Navigator.push(context, CupertinoPageRoute(builder: (context) => LandingPage(myID: _myID, myName: myName)));
                      }else {
                        setState(() {
                          _isEmailTrue = false;
                          _isPassTrue = false;
                        });
                      }
                    } else {
                      setState(() {
                        _isEmailTrue = false;
                        _isPassTrue = false;
                      });
                    }
                  },
                  child: const Text("Continue", style: TextStyle(fontSize: 20)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
