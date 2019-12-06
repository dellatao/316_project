import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
class Todo {
  final String title;
  final String description;

  Todo(this.title, this.description);
}
class CommentsPage extends StatefulWidget {
@override
createState() => new CommentsPageState();

final Todo todo;

CommentsPage({Key key, @required this.todo}) : super(key: key);
}

class CommentsPageState extends State<CommentsPage> with AutomaticKeepAliveClientMixin<CommentsPage>{
  List<String> _comments = [];
  bool get wantKeepAlive => true;
  List<bool> isFlaggedList = [];
  List<bool>isLikedList = [];
  List<bool>isDislikedList = [];
  List<int>flagCountList = [];
  List<int>likeCountList = [];
  List<int>dislikeCountList = [];
  Future<Comment> comment;
  final commentController = TextEditingController();

  void dispose() {
    // Clean up the controller when the widget is disposed.
    commentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    comment = fetchComment();
  }


  void _addComment(String val){
    if (val.length >0 ) {
      _comments.add(val);
      isFlaggedList.add(false);
      isLikedList.add(false);
      isDislikedList.add(false);
      flagCountList.add(0);
      likeCountList.add(0);
      dislikeCountList.add(0);
    }
  }

  void _removeComment(int index) {
    setState(() => _comments.removeAt(index));
  }
  Widget _buildCommentList() {
    return FutureBuilder<Comment>(
        future: comment,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if(_comments.indexOf(snapshot.data.body) == -1){
              _addComment(snapshot.data.body);}
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          return new ListView.builder(
            itemBuilder: (context, index) {
              // itemBuilder will be automatically be called as many times as it takes for the
              // list to fill up its available space
              if (index < _comments.length) {
                return _buildCommentItem(_comments[index], index);
              }
              return null;
            },
          );
        }
    );
  }



  void toggleCount(conditionBool, countList, conditionList, index) {
    setState(() {
      if (conditionBool) {
        countList[index] -= 1;
        conditionList[index] = false;
      } else {
        countList[index] += 1;
        conditionList[index] = true;
      }
    });
  }
  Widget _buildCommentItem(String comment, int index) {
    bool isFlagged = isFlaggedList[index];
    bool isLiked = isLikedList[index];
    bool isDisliked = isDislikedList[index];
    int flagCount = flagCountList[index];
    int likeCount = likeCountList[index];
    int dislikeCount = dislikeCountList[index];
    return new ListTile(

      title: new Text(comment),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      trailing: Row(mainAxisSize: MainAxisSize.min,
        children: <Widget> [
          IconButton(icon: Icon(Icons.flag),  color: isFlagged ? Colors.redAccent:null, iconSize: 30, onPressed: () {
            setState(() {
              //_pressed(isPressed);
              toggleCount(isFlagged, flagCountList, isFlaggedList, index);

            });
          }),
          Text(flagCount.toString()),
          IconButton(icon: Icon(Icons.keyboard_arrow_up),  color: isLiked ? Colors.deepPurpleAccent:null, iconSize: 30, onPressed: () {
            setState(() {
              //_pressed(isPressed);
              toggleCount(isLiked, likeCountList, isLikedList, index);
            });
          }),
          Text(likeCount.toString()),



          IconButton(icon: Icon(Icons.keyboard_arrow_down), color: isDisliked ? Colors.orangeAccent:null, iconSize: 30, onPressed: () {
            setState(() {
              toggleCount(isDisliked, dislikeCountList, isDislikedList, index);
            });
          }),
          Text(dislikeCount.toString()),
        ],
      ),

    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
            title: Text("Comments"),
            backgroundColor: new Color(0xFF131515)),
        body: Column(children: <Widget>[
          new ListTile(
              title: new Text(widget.todo.title),

              subtitle: new Text(widget.todo.description),
              contentPadding: const EdgeInsets.all(20.0)
          ),
          Expanded(child:_buildCommentList()),
          new TextField(
            controller: commentController,
            decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(20.0),
                hintText: "add a comment"

            ),
          ),
          FlatButton(
              child: Text('Submit'),
              onPressed: () {
                setState(() {
                _addComment(commentController.text);
                commentController.clear();
                });
              }
          ),

        ]));
  }
}


class Comment {
  final int cid;
  final int uid;
  final int pid;
  final String body;
  final DateTime deletedAt;


  Comment({this.cid, this.uid, this.pid, this.body, this.deletedAt});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
        cid: json['id'],
        uid: json['uid'],
        pid: json['pid'],
        body: json['body'],
        deletedAt: json['deletedAt']
    );
  }
}
Future<Comment> fetchComment() async {
  final response =
  await http.get('https://jsonplaceholder.typicode.com/comments/1');

  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON.
    return Comment.fromJson(json.decode(response.body));
  } else {
    // If that response was not OK, throw an error.
    throw Exception('Failed to load post');
  }
}