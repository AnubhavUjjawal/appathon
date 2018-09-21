import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'choose-file.dart';

class AddItem extends StatefulWidget {
  AddItem({this.app, this.itemsRef});
  DatabaseReference itemsRef;
  final FirebaseApp app;

  @override
  _AddItem createState() => new _AddItem(itemsRef: itemsRef);
}

class _AddItem extends State<AddItem> {
  _AddItem({this.itemsRef});
  final _formKey = GlobalKey<FormState>();
  final itemName = TextEditingController();
  DatabaseReference itemsRef;
  Map<String, double> _startLocation;
  Map<String, double> _currentLocation;

  StreamSubscription<Map<String, double>> _locationSubscription;

  Location _location = new Location();
  bool _permission = false;
  String error;

  bool currentWidget = true;
  final MAPAPIKEY = "AIzaSyBxOIz-0sskG8CgVWZFdSVawQ0P2VOjQoI"; 
  Image image1;
  // final

  initPlatformState() async {
    Map<String, double> location;
    // Platform messages may fail, so we use a try/catch PlatformException.

    try {
      _permission = await _location.hasPermission();
      location = await _location.getLocation();


      error = null;
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'Permission denied';
      } else if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error = 'Permission denied - please ask the user to enable it from the app settings';
      }

      location = null;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    //if (!mounted) return;

    setState(() {
        _startLocation = location;
    });

  }

  @override
    void initState() {
      // TODO: implement initState
      super.initState();
      initPlatformState();

    _locationSubscription =
        _location.onLocationChanged().listen((Map<String,double> result) {
          setState(() {
            _currentLocation = result;
          });
        });
    }
  @override
    Widget build(BuildContext context) {
      return new Scaffold(
        appBar: new AppBar(
          title: const Text('Add Item to Find It'),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(  //placeholder image instead of this maybe
                padding: EdgeInsets.only(bottom: 40.0),
              ),
              TextFormField(
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: "Item Name",
                  border: OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent))
                ),
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter the item name';
                  }
                },
                controller: itemName,
              ),
              _currentLocation != null?
              //   Image.network(
              //     "https://maps.googleapis.com/maps/api/staticmap?center=${_currentLocation["latitude"]},${_currentLocation["longitude"]}&zoom=18&size=640x400&markers=color:blue%7Clabel:S%7C${_currentLocation["latitude"]},${_currentLocation["longitude"]}&key=${MAPAPIKEY}"
              //   ): Text("MAP NOT ENABLED"),
              Text("Location: ${_currentLocation["latitude"]},${_currentLocation["longitude"]}"): Text("Loading Map"),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: RaisedButton(
                  onPressed: () async{
                    // Validate will return true if the form is valid, or false if
                    // the form is invalid.
                    if (_formKey.currentState.validate()) {
                      // If the form is valid, we want to show a Snackbar
                      print(itemName.text);
                      itemsRef.push().set(<String, String>{
                        "itemName": itemName.text,
                        "latitude": _currentLocation["latitude"].toString(),
                        "longitude": _currentLocation["longitude"].toString(),
                        "datetime": DateTime.now().toString()
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Add Item'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: RaisedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>MyHomePage(title: 'Image Picker')));
                  },
                  child: Text('Add Image'),
                ),
              ),
            ]
          ),
        ),
        // body: FirebaseAnimatedList(
        //   query: database.reference().child('${username}/added_items'),
        //   itemBuilder: (context, snapshot, animation, index) {
        //     // print("again");
        //     print(snapshot.value);
        //     return Column(children: <Widget>[
        //       ListTile(
        //         title: Text(
        //           snapshot.value["itemName"],
        //           style: TextStyle(fontSize: 20.0),
        //         ),
        //         onTap: ()=>print(snapshot.value),
        //       ),
        //     ]);
        //   }
        // ),
        floatingActionButton: new FloatingActionButton(
          onPressed: (){
            print("button pressed");
          },
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ),
      );
    }
}