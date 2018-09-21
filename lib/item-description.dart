import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'choose-file.dart';

class ItemDes extends StatefulWidget {
  ItemDes({this.app, this.val});
  DatabaseReference familyRef;
  final FirebaseApp app;
  dynamic val;

  @override
  _ItemDes createState() => new _ItemDes(val:val);
}

class _ItemDes extends State<ItemDes> {
  _ItemDes({this.val});
  final _formKey = GlobalKey<FormState>();
  final itemName = TextEditingController();
  DatabaseReference familyRef;
  String username;
  dynamic val;
  
  @override
  void initState() {
    super.initState();
    // Demonstrates configuring to the database using a file
    familyRef = FirebaseDatabase.instance.reference().child('${username}/family_members');
    // Demonstrates configuring the database directly
    familyRef.keepSynced(true);
  }
  @override
    void dispose() {
      itemName.dispose();
      super.dispose();
    }
  @override
    Widget build(BuildContext context) {
      // TODO: implement build
      return new Scaffold(
        appBar: new AppBar(
          title: const Text('Your Family Members'),
        ),
        body: Column(
          children: <Widget>[
            FirebaseAnimatedList(
              shrinkWrap: true,
              query: familyRef,
              itemBuilder: (context, snapshot, animation, index) {
                // print("again");
                print(snapshot.value);
                return Column(children: <Widget>[
                  ListTile(
                    title: Text(
                      snapshot.value["personName"],
                      style: TextStyle(fontSize: 20.0),
                    ),
                    onTap: ()=>print(snapshot.value),
                  ),
                ]);
              }
            ),
            Expanded(child: Container()),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Form(
                            key: _formKey,
                            child: TextFormField(
                            autocorrect: false,
                            decoration: InputDecoration(
                              labelText: "Person Name",
                              border: OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent))
                            ),
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.black
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter the Family person name';
                              }
                            },
                            controller: itemName,
                          ),
                        )
                      ),
                      
                    ],
                  ),
                ),
              FloatingActionButton(
                onPressed: (){
                  if (_formKey.currentState.validate()) {
                      // If the form is valid, we want to show a Snackbar
                      print(itemName.text);
                      familyRef.push().set(<String, String>{
                        "personName": itemName.text,
                        "datetime": DateTime.now().toString()
                      });
                      // Navigator.pop(context);
                    }
                },
                tooltip: 'Increment',
                child: const Icon(Icons.add),
              ),
              // RaisedButton(
              //     onPressed: () async{
              //       // Validate will return true if the form is valid, or false if
              //       // the form is invalid.
                    // if (_formKey.currentState.validate()) {
                    //   // If the form is valid, we want to show a Snackbar
                    //   print(itemName.text);
                    //   // itemsRef.push().set(<String, String>{
                    //   //   "itemName": itemName.text,
                    //   //   "latitude": _currentLocation["latitude"].toString(),
                    //   //   "longitude": _currentLocation["longitude"].toString(),
                    //   //   "datetime": DateTime.now().toString()
                    //   // });
                    //   Navigator.pop(context);
                    // }
              //     },
              //     child: Text('Add Item'),
              //   ),
            ],
          )
          ]
        )
      );
    }
}