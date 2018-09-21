import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:intl/intl.dart';


class FamilyMembersPage extends StatefulWidget {
  FamilyMembersPage({this.familyName, this.username, this.app});
  // final FirebaseApp app;
  dynamic familyName; String username;
  final FirebaseApp app;

  @override
  _FamilyMembersPageState createState() => new _FamilyMembersPageState(familyName: this.familyName, username: this.username);
}

class _FamilyMembersPageState extends State<FamilyMembersPage> {
  _FamilyMembersPageState({this.familyName, this.username, this.app});
  String username; //username is hardcoded since there is no login as of now.
  dynamic familyName;
  int _counter;
  DatabaseReference _itemsRef;
  DatabaseReference _familyRef;
  DatabaseReference _addedItems;
  StreamSubscription<Event> _counterSubscription;
  StreamSubscription<Event> _messagesSubscription;
  bool _anchorToBottom = false;
  FirebaseDatabase database;
  DatabaseError _error;
  final FirebaseApp app;

  @override
  void initState() {
    super.initState();
    // Demonstrates configuring to the database using a file
    _itemsRef = FirebaseDatabase.instance.reference().child('${familyName["personName"]}/added_items');
    _itemsRef.keepSynced(true);
    
  }

  @override
  void dispose() {
    super.dispose();
    _messagesSubscription.cancel();
    _counterSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Retrieve Family Items'),
      ),
      body: FirebaseAnimatedList(
        query: _itemsRef,
        itemBuilder: (context, snapshot, animation, index) {
          // print("again");
          print(snapshot.value);
          return Column(children: <Widget>[
             ExpansionTile(
              title: new Text(snapshot.value["itemName"].toString(),
                style: new TextStyle(
                  fontSize: 20.0
                ),
              ),
              children: <Widget>[
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(DateFormat('d MMMM EEEE H:m').format(DateTime.parse(snapshot.value["datetime"].toString())) ,
                          style: new TextStyle(
                            fontSize: 15.0
                          ),), 
                            ),
                            
                          ],
                        ),
                      ),
                    FloatingActionButton(
                      onPressed: (){
                        FirebaseDatabase.instance.reference().child('${familyName["personName"]}/added_items/${snapshot.key}').remove();
                      },
                      tooltip: 'Increment',
                      child: const Icon(Icons.delete),
                    ),
                    
                  ],
                )
              ],
            ),
          ]);
        }
      ),
    );
  }
}