import 'package:blood_donor/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'backend_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  final UserRec userAccount;
  HomeScreen(
    this.userAccount,
  );
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String result = '';

  bool permissions;

  Stream<DocumentSnapshot> _firebaseStream;

  bool isSubscribed = true;
  @override
  void initState() {
    super.initState();

    _firebaseStream = FirebaseFirestore.instance
        .collection('unverifiedUsers')
        .doc("${Auth().getUser().user.uid}")
        .snapshots();
  }

  String sensorSteps = "";
  static BuildContext temp;
  static const methodChannel =
      const MethodChannel('wingquest.stablekernel.io/speech');
  RangeValues _dateRange = RangeValues(1, 8);
  List<DateTime> _dates = List<DateTime>();
  DateTime get _dateFrom => _dates[_dateRange.start.round()];
  DateTime get _dateTo => _dates[_dateRange.end.round()];
  Future<void> _didRecieveTranscript(MethodCall call) async {
    // type inference will work here avoiding an explicit cast
    print("WAS CALLED!");
    final String utterance = call.arguments;
    switch (call.method) {
      case "didRecieveTranscript":
        {
          print("it works!$utterance");
          setState(() {
            sensorSteps = utterance;
          });
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    temp = context;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Welcome ${widget.userAccount.user.displayName}!",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: "Roboto",
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              child: Column(
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.red,
                    radius: 50.0,
                    child: Icon(
                      Icons.account_circle,
                      size: 100,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "${widget.userAccount.user.displayName}",
                    style: TextStyle(
                      // color: Colors.white,
                      fontSize: 20,
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              onTap: () {
                //
              },
              leading: Icon(Icons.home),
              title: Text(
                "Home",
                style: TextStyle(
                  fontFamily: "Roboto",
                  fontSize: 20,
                ),
              ),
            ),
            ListTile(
              onTap: () {
                //
              },
              leading: Icon(Icons.accessibility),
              title: Text(
                "BMI Calculator",
                style: TextStyle(
                  fontFamily: "Roboto",
                  fontSize: 20,
                ),
              ),
            ),
            ListTile(
              onTap: () {
                //
              },
              leading: Icon(Icons.settings),
              title: Text(
                "Settings",
                style: TextStyle(
                  fontFamily: "Roboto",
                  fontSize: 20,
                ),
              ),
            ),
            ListTile(
              onTap: () {
                Auth auth = new Auth();
                auth.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (_) => LoginScreen(),
                  ),
                );
              },
              leading: Icon(Icons.logout),
              title: Text(
                "Sign out",
                style: TextStyle(
                  fontFamily: "Roboto",
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor:
          MediaQuery.of(context).platformBrightness == Brightness.dark
              ? Colors.grey.shade900
              : Colors.white,
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firebaseStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          if (snapshot.data.data()["status"] == "accepted")
            return Center(
              child:
                  Text("Congratulations! Your application has been accepted!"),
            );
          else if (snapshot.data.data()["status"] == "rejected")
            return Center(
              child: Text("Your application has been rejected"),
            );
          else {
            return Center(
              child: Text("Your application is yet to be approved"),
            );
          }
        },
      ),
    );
  }

  String _dateToString(DateTime dateTime) {
    if (dateTime == null) {
      return 'null';
    }

    return '${dateTime.day}.${dateTime.month}.${dateTime.year}';
  }
/*
  Widget _buildDateSlider(BuildContext context) {
    return Row(
      children: [
        Text('Date Range'),
        Expanded(
          child: RangeSlider(
            values: _dateRange,
            min: 0,
            max: 9,
            divisions: 10,
            onChanged: (values) => setState(() => _dateRange = values),
          ),
        ),
      ],
    );
  }

  Widget _buildLimitSlider(BuildContext context) {
    return Row(
      children: [
        Text('Limit'),
        Expanded(
          child: Slider(
            value: _limitRange,
            min: 0,
            max: 4,
            divisions: 4,
            onChanged: (newValue) => setState(() => _limitRange = newValue),
          ),
        ),
      ],
    );
  }*/

  Widget _buildButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FlatButton(
            color: Theme.of(context).accentColor,
            textColor: Colors.white,
            onPressed: () {},
            child: Text('Read'),
          ),
        ),
        Padding(padding: EdgeInsets.symmetric(horizontal: 4)),
        Expanded(
          child: FlatButton(
            color: Theme.of(context).accentColor,
            textColor: Colors.white,
            onPressed: () {},
            child: Text('Revoke permissions'),
          ),
        ),
      ],
    );
  }
}
