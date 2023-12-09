import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemProduct extends StatefulWidget {
  const ItemProduct({Key? key}) : super(key: key);

  @override
  _ItemProductState createState() => _ItemProductState();
}

class _ItemProductState extends State<ItemProduct> {
  var collection = FirebaseFirestore.instance.collection("users");
  late List<Map<String, dynamic>> items;
  bool isLoaded = false;



  @override
  void initState() {
    super.initState();
    _incrementCounter();
  }

  _incrementCounter() async {
    List<Map<String, dynamic>> tempList = [];
    var data = await collection.get();

    data.docs.forEach((element) {
      tempList.add(element.data());
    });

    setState(() {
      items = tempList;
      isLoaded = true;
    });
  }

  _showDeleteOptions(String userId) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete User'),
              onTap: () {
                _deleteUser(userId);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  _deleteUser(String userId) async {
    await collection.doc(userId).delete();
    // You may also want to perform additional cleanup or actions after deletion
    _incrementCounter(); // Refresh the list after deletion
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 20),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Icon(Icons.person),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Here is Product Title', style: Theme.of(context).textTheme.headline6),
                const SizedBox(height: 5),
                Text(
                  'Here is the description of this project, kindly read it carefully. We offer 10% discount on this product.',
                  style: Theme.of(context).textTheme.bodyText2?.copyWith(height: 1.5),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text('Rs.500 PKR',
                    style: Theme.of(context).textTheme.subtitle1?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ))
              ],
            ),
          )
        ],
      ),
    );
  }
}
