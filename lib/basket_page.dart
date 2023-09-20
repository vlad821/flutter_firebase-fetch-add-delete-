import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/item.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

// Assuming you have an 'Item' class defined with appropriate properties and toJson() method.

const COLLECTION_NAME = 'basket_items';

class BasketPage extends StatefulWidget {
  const BasketPage({super.key});

  @override
  State<BasketPage> createState() => _BasketPageState();
}

class _BasketPageState extends State<BasketPage> {
  List<Item> basketItems = [];

  @override
  void initState() {
    fetchRecords();
    FirebaseFirestore.instance
        .collection(COLLECTION_NAME)
        .snapshots()
        .listen((records) {
      mapRecords(records);
    });

    super.initState();
  }

  fetchRecords() async {
    var records =
        await FirebaseFirestore.instance.collection(COLLECTION_NAME).get();

    mapRecords(records);
  }

  mapRecords(QuerySnapshot<Map<String, dynamic>> records) {
    var _list = records.docs
        .map(
          (item) =>
              Item(id: item.id, name: item['name'], quantity: item['quantity']),
        )
        .toList(); // Add parentheses to call the 'toList' method

    setState(() {
      basketItems = _list;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: showItemDialog,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: basketItems.length,
        itemBuilder: (context, index) {
          return Slidable(
              endActionPane: ActionPane(motion: ScrollMotion(), children: [
                SlidableAction(
                  onPressed: (c) {
                    deleteItem(basketItems[index].id);
                  },
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Delete',
                  spacing: 8,
                )
              ]),
              child: ListTile(
                title: Text(basketItems[index].name),
                subtitle: Text(basketItems[index].quantity),
              ));
        },
      ),
    );
  }

  showItemDialog() {
    var nameController = TextEditingController();
    var quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Text('Item details'),
                TextField(
                  controller: nameController,
                ),
                TextField(
                  controller: quantityController,
                ),
                TextButton(
                  onPressed: () {
                    var name = nameController.text.trim();
                    var quantity = quantityController.text.trim();
                    addItem(name, quantity);
                    Navigator.pop(context);
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  addItem(String name, String quantity) {
    var item = Item(id: 'id', name: name, quantity: quantity);
    FirebaseFirestore.instance.collection(COLLECTION_NAME).add(item.toJson());
  }

  deleteItem(String id) {
    FirebaseFirestore.instance.collection(COLLECTION_NAME).doc(id).delete();
  }
}
