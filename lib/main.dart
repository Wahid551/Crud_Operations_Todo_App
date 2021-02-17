import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final db = FirebaseFirestore.instance;
  String task;
  void showdialog(bool isUpdate, String id) {
    GlobalKey<FormState> formkey = GlobalKey<FormState>();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: isUpdate ? Text('Update Todo') : Text('Add Todo'),
            content: Form(
              key: formkey,
              child: TextFormField(
                autofocus: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Task',
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return "Can't Be Empty";
                  } else {
                    return null;
                  }
                },
                onChanged: (val) {
                  task = val;
                },
              ),
            ),
            actions: [
              RaisedButton(
                onPressed: () {
                  if (isUpdate) {
                    db
                        .collection('crud')
                        .doc(id)
                        .update({'task': task, 'time': DateTime.now()});
                  } else {
                    db
                        .collection('crud')
                        .add({'task': task, 'time': DateTime.now()});
                  }
                  Navigator.pop(context);
                },
                child: Text('Add'),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => showdialog(false, null),
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: Text('Crud Operations'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: db.collection('crud').orderBy('time').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                //DocumentSnapshot dc=snapshot.data.docs[index];
                return Container(
                  child: ListTile(
                    //title: Text(dc['index']),
                    title: Text(snapshot.data.docs[index].data()['task']),
                    onLongPress: () {
                      // Deleted
                      db
                          .collection('crud')
                          .doc(snapshot.data.docs[index].id)
                          .delete();
                      // Also used
                      //db.collection('task').doc(ds.documentID).delete();
                    },
                    onTap: () {
                      //Updated
                      // db
                      //     .collection('crud')
                      //     .doc(snapshot.data.docs[index].id)
                      //     .update({'task': "new value"});
                      showdialog(true, snapshot.data.docs[index].id);
                    },
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return CircularProgressIndicator();
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
