import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class TestFirestore extends StatefulWidget {
  const TestFirestore({super.key});

  @override
  State<TestFirestore> createState() => _TestFirestoreState();
}

class _TestFirestoreState extends State<TestFirestore> {
  var db = FirebaseFirestore.instance;
  final bang = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: bang,
        ),
        actions: [
          IconButton(
              onPressed: (() {
                final user = <String, dynamic>{
                  "first": bang.text,
                  "last": "oiittt",
                  "born": 1815
                };

                db.collection("users").add(user).then((DocumentReference doc) =>
                    print('DocumentSnapshot added with ID: ${doc.id}'));
              }),
              icon: Icon(Icons.add))
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: db.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error"),
            );
          }

          // OLAH DATA
          var _data = snapshot.data!.docs;

          return ListView.builder(
            itemCount: _data.length,
            itemBuilder: (context, index) {
              return ListTile(
                onLongPress: () {
                  // hapus otomatis ketika ditekan lama
                  // versi simple
                  // _data[index].reference.delete();
                  // versi apalah
                  _data[index].reference.delete().then((value) =>
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("data removed"))));

                  db.collection("cities").doc("DC").delete().then(
                      (doc) => print("document deleted"),
                      onError: (e) => print("error updating document $e"));
                },
                subtitle: Text(_data[index].data()['born'].toString()),
                // title: Text(_data[index].data().toString()),
                title: Text(_data[index].data()['first'] + " "),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (() {
          final user = <String, dynamic>{"first": bang.text, "born": 1815};

          db.collection("users").add(user).then((DocumentReference doc) =>
              print('DocumentSnapshot added with ID: ${doc.id}'));
        }),
        child: const Icon(Icons.add),
      ),
    );
  }
}
