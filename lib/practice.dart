import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

Future<void> main() async {
  final FirebaseApp app = await FirebaseApp.configure(
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
  int _counter;
  DatabaseReference _counterRef;
  DatabaseReference _toDo;
  DatabaseReference _messagesRef;
  StreamSubscription<Event> _toDoSubscription;
  StreamSubscription<Event> _counterSubscription;
  StreamSubscription<Event> _messagesSubscription;
  bool _anchorToBottom = false;

  String _kTestKey = 'Hello';
  String _kTestValue = 'world!';
  DatabaseError _error;
  
  FirebaseDatabase db;
  dynamic items;
  
  @override
  void initState() {
    super.initState();
    // Demonstrates configuring to the database using a file
    _counterRef = FirebaseDatabase.instance.reference().child('counter');
    _toDo = FirebaseDatabase.instance.reference().child('to-do');
    db = new FirebaseDatabase(app: widget.app);
    db.reference().child('to-do').once().then((DataSnapshot snapshot){
      print('${snapshot.value}');
      // snapshot.value.forEach((k, v)=>print('${k}, ${v}'));
    });
    db.reference().child('to-do').keepSynced(true);
    db.setPersistenceEnabled(true);
    db.setPersistenceCacheSizeBytes(10000000);
    _toDoSubscription = db.reference().child('to-do').onValue.listen((Event event){
      // print('${event.snapshot.value}');
      // for(int i=0; i<event.snapshot.value.length; i++){
      //   // print({"fuck": "yeah"});
      //   print(event.snapshot.value["To-do"]);
      // }
      // setState(() {
      //     items = event.snapshot.value;   
      // });
      // event.snapshot.value.forEach((k, v)=>print('${k}, ${v}'));
    });
    // Demonstrates configuring the database directly
    final FirebaseDatabase database = new FirebaseDatabase(app: widget.app);
    _messagesRef = database.reference().child('messages');
    database.reference().child('counter').once().then((DataSnapshot snapshot) {
      print('Connected to second database and read ${snapshot.value}');
    });
    database.setPersistenceEnabled(true);
    database.setPersistenceCacheSizeBytes(10000000);
    _counterRef.keepSynced(true);
    _counterSubscription = _counterRef.onValue.listen((Event event) {
      setState(() {
        _error = null;
        _counter = event.snapshot.value ?? 0;
      });
    }, onError: (Object o) {
      final DatabaseError error = o;
      setState(() {
        _error = error;
      });
    });
    _messagesSubscription =
        _messagesRef.limitToLast(10).onChildAdded.listen((Event event) {
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
        await _counterRef.runTransaction((MutableData mutableData) async {
      mutableData.value = (mutableData.value ?? 0) + 1;
      return mutableData;
    });

    if (transactionResult.committed) {
      _messagesRef.push().set(<String, String>{
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
    final TransactionResult transactionResult =
        await _toDo.runTransaction((MutableData mutableData) async {
        print(mutableData.value.keys);
        _toDo.push().set(<String, String>{
          _kTestKey: "Anurag Gupta"
        });
      return mutableData;
    });

    if (transactionResult.committed) {
      _messagesRef.push().set(<String, String>{
        _kTestKey: '$_kTestValue ${transactionResult.dataSnapshot.value}'
      });
    } else {
      print('Transaction not committed.');
      if (transactionResult.error != null) {
        print(transactionResult.error.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('To-Do List'),
      ),
      body: FirebaseAnimatedList(
        query: db.reference().child('to-do'),
        itemBuilder: (context, snapshot, animation, index) {
          print("again");
          print(snapshot.value);
          return Column(children: <Widget>[
            ListTile(
              title: Text(
                snapshot.value.toString(),
                style: TextStyle(fontSize: 20.0),
              ),
            ),
          ]);
        }
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _sendData,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}