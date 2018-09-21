import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'add-item.dart';
import 'family-members.dart';
import 'package:intl/intl.dart';

FirebaseApp app;
Future<void> main() async {
  app = await FirebaseApp.configure(
    name: 'db1',
    options: const FirebaseOptions(
            googleAppID: '1:494817341579:android:dbda721404f4742f',
            apiKey: 'AIzaSyBxOIz-0sskG8CgVWZFdSVawQ0P2VOjQoI',
            databaseURL: 'https://appathon-e5eba.firebaseio.com',
          ),
  );
  runApp(new MaterialApp(
    title: 'Flutter Database Example',
    home: new MyHomePage(app: app),
  ));
  // runApp(new MyApp());
}

// void main() => runApp(new MyApp());

// class MyApp extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return new MaterialApp(
//       title: 'Flutter Demo',
//       theme: new ThemeData(
//         // This is the theme of your application.
//         //
//         // Try running your application with "flutter run". You'll see the
//         // application has a blue toolbar. Then, without quitting the app, try
//         // changing the primarySwatch below to Colors.green and then invoke
//         // "hot reload" (press "r" in the console where you ran "flutter run",
//         // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
//         // counter didn't reset back to zero; the application is not restarted.
//         primarySwatch: Colors.blue,
//       ),
//       home: new MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

class MyHomePage extends StatefulWidget {
  MyHomePage({this.app});
  final FirebaseApp app;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final username = "anubhav_u16"; //username is hardcoded since there is no login as of now.
  int _counter;
  DatabaseReference _itemsRef;
  DatabaseReference _familyRef;
  DatabaseReference _addedItems;
  StreamSubscription<Event> _counterSubscription;
  StreamSubscription<Event> _messagesSubscription;
  bool _anchorToBottom = false;
  FirebaseDatabase database;
  String _kTestKey = 'Hello';
  String _kTestValue = 'world!';
  DatabaseError _error;

  @override
  void initState() {
    super.initState();
    // Demonstrates configuring to the database using a file
    _itemsRef = FirebaseDatabase.instance.reference().child('${username}/added_items');
    _familyRef = FirebaseDatabase.instance.reference().child('${username}/family_members');
    // Demonstrates configuring the database directly
    database = new FirebaseDatabase(app: widget.app);
    _addedItems = database.reference().child(username);
    database.reference().child('${username}/added_items').once().then((DataSnapshot snapshot) {
      print('Connected to second database and read ${snapshot.value}');
    });
    database.setPersistenceEnabled(true);
    database.setPersistenceCacheSizeBytes(10000000);
    _itemsRef.keepSynced(true);
    // _counterSubscription = _itemsRef.onValue.listen((Event event) {
    //   setState(() {
    //     _error = null;
    //     _counter = event.snapshot.value ?? 0;
    //   });
    // }, onError: (Object o) {
    //   final DatabaseError error = o;
    //   setState(() {
    //     _error = error;
    //   });
    // });
    _messagesSubscription =
        _addedItems.limitToLast(10).onChildAdded.listen((Event event) {
      print('Child added: ${event.snapshot.value}');
    }, onError: (Object o) {
      final DatabaseError error = o;
      print('Error: ${error.code} ${error.message}');
    });
  }

  @override
  void dispose() {
    super.dispose();
    _messagesSubscription.cancel();
    _counterSubscription.cancel();
  }

  Future<Null> _increment() async {
    // Increment counter in transaction.
    final TransactionResult transactionResult =
        await _itemsRef.runTransaction((MutableData mutableData) async {
      mutableData.value = (mutableData.value ?? 0) + 1;
      return mutableData;
    });

    if (transactionResult.committed) {
      _addedItems.push().set(<String, String>{
        _kTestKey: '$_kTestValue ${transactionResult.dataSnapshot.value}'
      });
    } else {
      print('Transaction not committed.');
      if (transactionResult.error != null) {
        print(transactionResult.error.message);
      }
    }
  }
  
Future<Null> _sendData() async {
    // Increment counter in transaction.
      _itemsRef.push().set(<String, String>{
          "itemName": "Shoes",
          "itemCount": "2",
          "datetime": DateTime.now().toString()
        });
    }

  @override
  Widget build(BuildContext context) {
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
              title: Text("Your Family Members",
                style: new TextStyle(
                  fontSize: 18.0
                ),
              ),
              onTap: (){
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context)=>FamilyMembers(app: app, familyRef: _familyRef, username: username,)));
              },
            ),
          ],
        ),
      ),
      appBar: new AppBar(
        title: const Text('Find It'),
      ),
      body: FirebaseAnimatedList(
        query: database.reference().child('${username}/added_items'),
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
                // new Padding(
                //   padding: EdgeInsets.all(12.0),
                //   child: new Text(snapshot.value["datetime"].toString(),
                //     style: new TextStyle(
                //       fontSize: 15.0
                //     ),),
                // ),
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
                        database.reference().child('${username}/added_items/${snapshot.key}').remove();
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
      floatingActionButton: new FloatingActionButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>AddItem(app: app, itemsRef: _itemsRef,)));
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}