import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class AdminUserPage extends StatefulWidget {
  const AdminUserPage({super.key});

  @override
  State<AdminUserPage> createState() => _AdminUserPageState();
}

class _AdminUserPageState extends State<AdminUserPage> {
  var collection = FirebaseFirestore.instance.collection("users");
  late List<Map<String, dynamic>> items;
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    _incrementCounter();
  }
  _incrementCounter () async {
    List<Map<String, dynamic>> tempList = [];
    var data = await collection.get();

    data.docs.forEach((element){
      tempList.add(element.data());
    });

    setState(() {
      items = tempList;
      isLoaded = true;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

       body: Center(
        child: isLoaded? ListView.builder(
         itemCount: items.length,
           itemBuilder: (context, index){
           return Padding(
               padding: const EdgeInsets.all(8.0),
             child: ListTile(
             shape: RoundedRectangleBorder(
             side: const BorderSide(width: 2),
             borderRadius: BorderRadius.circular(20)
             ),
             leading: const CircleAvatar(
             backgroundColor: Color(0xff6ae792),
             child: Icon(Icons.person)
             ),
             title: Row(
             children: [
               Text(items[index]["username"]?? "not given"),
              SizedBox(width: 10,),
             Text(items[index]["isAdmin"].toString())
             ],
             ),
             subtitle: Text(items[index]["uid"]),
             trailing: Icon(Icons.more_vert),
             ),
           );
           }
        ): Text("no data")
           )
       );

  }
}

