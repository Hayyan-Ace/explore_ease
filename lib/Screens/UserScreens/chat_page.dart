import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../Services/chat_service.dart';
import '../../Widgets/message_tile.dart';
import '../../Widgets/widgets.dart';
import 'group_info.dart';

class Chat extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;

  const Chat({
    Key? key,
    required this.groupId,
    required this.groupName,
    required this.userName,
  }) : super(key: key);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  Stream<QuerySnapshot>? chats;
  TextEditingController messageController = TextEditingController();
  String admin = "";
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getChatandAdmin();
  }

  getChatandAdmin() {
    DatabaseService().getChats(widget.groupId).then((val) {
      setState(() {
        chats = val;
      });
    });
    DatabaseService().getGroupAdmin(widget.groupId).then((val) {
      setState(() {
        admin = val;
      });
    });
  }

  Color myColor = const Color(0xFFa2d19f);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: myColor,
        centerTitle: true,
        elevation: 0,
        title: Text(
          widget.groupName,
          style: const TextStyle(
            color: Colors.black,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              nextScreen(
                context,
                GroupInfo(
                  groupId: widget.groupId,
                  groupName: widget.groupName,
                  adminName: admin,
                ),
              );
            },
            icon: const Icon(Icons.info),
            color: Colors.grey[500],
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatMessages(
              chats: chats,
              userName: widget.userName,
              scrollController: _scrollController,
            ),
          ),
          SendMessageContainer(
            messageController: messageController,
            sendMessage: sendMessage,
          ),
        ],
      ),
    );
  }

  void sendMessage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "sender": widget.userName,
        "time": DateTime.now().millisecondsSinceEpoch,
      };

      DatabaseService().sendMessage(widget.groupId, chatMessageMap);
      messageController.clear();
    }
  }
}

class ChatMessages extends StatelessWidget {
  final Stream<QuerySnapshot>? chats;
  final String userName;
  final ScrollController scrollController;

  const ChatMessages({
    Key? key,
    required this.chats,
    required this.userName,
    required this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        WidgetsBinding.instance!.addPostFrameCallback((_) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });

        return ListView.builder(
          controller: scrollController,
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            return MessageTile(
              message: snapshot.data.docs[index]['message'],
              sender: snapshot.data.docs[index]['sender'],
              sentByMe: userName == snapshot.data.docs[index]['sender'],
            );
          },
        );
      },
    );
  }
}

class SendMessageContainer extends StatelessWidget {
  final TextEditingController messageController;
  final VoidCallback sendMessage;

  const SendMessageContainer({
    Key? key,
    required this.messageController,
    required this.sendMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[700],
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: messageController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Send a message...",
                hintStyle: TextStyle(color: Colors.white, fontSize: 16),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: sendMessage,
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFa2d19f),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Center(
                child: Icon(
                  Icons.send,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
