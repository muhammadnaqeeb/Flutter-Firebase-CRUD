import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Refer to collection(table like) which we created
  final CollectionReference _products =
      FirebaseFirestore.instance.collection("products");

  /*
  CRUD operation in nutshell
  await _products.add({"name": name, "price": price});
  await _products.update({"name": name, "price": price});
  await _products.doc(productId).delete();
  */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // StreamBuilder help us to create a presistence connection with firestore database
      // As we update date because of streamBuilder we get updated data in real time immedatity
      body: StreamBuilder(
        //snapshots are comming from products, this stream help us to create presistant connection
        //with database collection
        stream: _products.snapshots(),
        // streamSnapshot will have all the data, which is avaible in the database(firestore)
        builder: ((context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          // check for data
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length, //no. of rows
              itemBuilder: ((context, index) {
                // A [DocumentSnapshot] contains data read from a document in your [FirebaseFirestore] database
                // Single-single documents
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    // field: name and price
                    title: Text(documentSnapshot['name']),
                    subtitle: Text(
                      documentSnapshot['price'].toString(),
                    ),
                  ),
                );
              }),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        }),
      ),
    );
  }
}
