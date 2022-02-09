import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mychatapp/Screens/Contacts.dart';

class AddMembersINGroup extends StatefulWidget {
  final String groupChatId, name;
  final List membersList;
  const AddMembersINGroup(
      {required this.name,
      required this.membersList,
      required this.groupChatId,
      Key? key})
      : super(key: key);

  @override
  _AddMembersINGroupState createState() => _AddMembersINGroupState();
}

class _AddMembersINGroupState extends State<AddMembersINGroup> {
  final TextEditingController _search = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  List membersList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    membersList = widget.membersList;
  }

  void onSearch() async {
    setState(() {
      isLoading = true;
    });

    await _firestore
        .collection('users')
        .where("name", isEqualTo: _search.text)
        .get()
        .then((value) {
      setState(() {
        userMap = value.docs[0].data();
        isLoading = false;
        _search.clear();
      });
      print(userMap);
    });
  }

  void onAddMembers() async {
    membersList.add({
      "name": userMap!['name'],
      "email": userMap!['email'],
      "uid": userMap!['uid'],
      "isAdmin": false,
    });

    await _firestore.collection('groups').doc(widget.groupChatId).update({
      "members": membersList,
    });

    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('groups')
        .doc(widget.groupChatId)
        .set({
      "name": widget.name,
      "id": widget.groupChatId,
    });
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => HomeScreen()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        foregroundColor: Colors.redAccent,
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 25.0,
          ),
        ),
        title: Text(
          "Add other Members.",
          style: TextStyle(
            fontSize: 19.0,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.normal,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 90.0,
            width: 300.0,
            alignment: Alignment.center,
            child: Container(
              padding: EdgeInsets.only(
                left: 33.0,
              ),
              height: 60.0,
              width: 310.0,
              child: TextField(
                controller: _search,
                decoration: InputDecoration(
                  hintText: "Search",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 15.0,
          ),
          isLoading
              ? Container(
                  height: size.height / 12,
                  width: size.height / 12,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(
                    color: Colors.orange,
                  ),
                )
              : RaisedButton(
                  color: Colors.redAccent,
                  textColor: Colors.white,
                  onPressed: onSearch,
                  child: Text("S E A R C H"),
                ),
          SizedBox(
            height: size.height / 30,
          ),
          userMap != null
              ? ListTile(
                  leading: Icon(
                    Icons.person,
                    color: Colors.deepOrange,
                    size: 28,
                  ),
                  title: Text(userMap!['name']),
                  subtitle: Text(userMap!['email']),
                  trailing: IconButton(
                    onPressed: onAddMembers,
                    icon: Icon(
                      Icons.add,
                      color: Colors.black87,
                      size: 20,
                    ),
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
