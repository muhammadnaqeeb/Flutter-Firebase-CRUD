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

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  Future<void> _update(DocumentSnapshot? documentSnapshot) async {
    if (documentSnapshot != null) {
      // when thest fields are shown up they will be filled with previous data
      _nameController.text = documentSnapshot["name"];
      _priceController.text = documentSnapshot["price"].toString();
    }

    // when user click update a bottom sheat will come, where user enter data
    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              // prevent the soft keyboard from converting text fields
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            // take as many height as it required
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  final String name = _nameController.text;
                  final double? price = double.tryParse(_priceController.text);

                  if (price != null) {
                    await _products
                        .doc(documentSnapshot!.id)
                        .update({"name": name, "price": price});

                    _nameController.text = "";
                    _priceController.text = "";
                  }
                },
                child: const Text("Update"),
              )
            ],
          ),
        );
      },
    );
  }

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
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              // documentSnapshot is a single document which is comming from streamSnapshot.data!.docs[index];
                              _update(documentSnapshot);
                            },
                            icon: const Icon(
                              Icons.edit,
                            ),
                          )
                        ],
                      ),
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
