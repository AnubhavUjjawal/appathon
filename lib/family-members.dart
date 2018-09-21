import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'family-member-items.dart';
import 'main.dart';

class FamilyMembers extends StatefulWidget {
  FamilyMembers({this.app, this.familyRef, this.username});
  DatabaseReference familyRef;
  final FirebaseApp app;
  String username;

  @override
  _FamilyMembers createState() => new _FamilyMembers(familyRef: familyRef, username:username, app: app);
}

class _FamilyMembers extends State<FamilyMembers> {
  _FamilyMembers({this.familyRef, this.username, this.app});
  final FirebaseApp app;
  final _formKey = GlobalKey<FormState>();
  final itemName = TextEditingController();
  DatabaseReference familyRef;
  String username;
  
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
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              DrawerHeader(
                child: Text("Find It App",
                textAlign: TextAlign.center,
                  style: new TextStyle(
                    color: Colors.black,
                    fontSize: 22.0,
                  ),
                ),
                decoration: BoxDecoration(
                  color: Colors.blueAccent
                ),
              ),
              ListTile(
                leading: Icon(Icons.people),
                title: Text("Your Items",
                  style: new TextStyle(
                    fontSize: 18.0
                  ),
                ),
                onTap: (){
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>MyHomePage()));
                },
              ),
            ],
          ),
        ),
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
                    onTap: (){
                      print(snapshot.value);
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>FamilyMembersPage(familyName: snapshot.value, username: username, app:app)));
                    },
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
            ],
          )
          ]
        )
      );
    }
}