import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'vortex.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'comments.dart';
import 'dart:convert';
import 'dart:convert' as convert;
import 'user.dart';
import 'vortex.dart';

class Todo {
  final String title;
  final String description;

  Todo(this.title, this.description);
}
class CommentsPage extends StatefulWidget {
@override
createState() => new CommentsPageState();

final Todo todo;
final int pid;
final User user;

CommentsPage({Key key, @required this.todo, @required this.pid, @required this.user}) : super(key: key);
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
  List<int>cids = [];
  Future<List<Comment>> comment;
  final commentController = TextEditingController();

  void dispose() {
    // Clean up the controller when the widget is disposed.
    commentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    comment = fetchComments(http.Client(), widget.pid);
  }


  void _addComment(String val, int cid){
    if (val.length >0 ) {
      _comments.add(val);
      isFlaggedList.add(false);
      isLikedList.add(false);
      isDislikedList.add(false);
      flagCountList.add(0);
      likeCountList.add(0);
      dislikeCountList.add(0);
      cids.add(cid);
    }
  }

  void _removeComment(int index) {
    setState(() => _comments.removeAt(index));
  }
  Widget _buildCommentList() {
    return FutureBuilder<List<Comment>>(
        future: fetchComments(http.Client(), widget.pid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _addExistingItems(snapshot.data);
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


  void _addExistingItems(final List<Comment> comments) {
    for (var c in comments) {
      if (! cids.contains(c.cid)) {
        _comments.add(c.context);
        isFlaggedList.add(false);
        isLikedList.add(false);
        isDislikedList.add(false);
        flagCountList.add(0);
        likeCountList.add(0);
        dislikeCountList.add(0);
        cids.add(c.cid);
      }
    }
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
            //setState(() {
              //_pressed(isPressed);
              toggleCount(isFlagged, flagCountList, isFlaggedList, index);

            //});
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
        appBar: AppBar(
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop() //Navigator.push(
                      //context,
                      //MaterialPageRoute(builder: (context) => VortexApp(user: widget.user))),
          ),
          title: Text("Comments"),
          backgroundColor:  new Color(0xFF131515)),

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

                Future<Comment> newcomment = _makeCommentRequest(widget.user.uid, widget.pid, commentController.text);
                newcomment.then((value) => _addComment(commentController.text, value.cid));

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
  final String context;
  final DateTime deletedAt;


  Comment({this.cid, this.uid, this.pid, this.context, this.deletedAt});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
        cid: json['cid'],
        uid: json['uid'],
        pid: json['pid'],
        context: json['context'],
        deletedAt: json['deletedAt']
    );
  }
}

Future<List<Comment>> fetchComments(http.Client client, int pid) async {

  print ("fetching");
  final response =
  await client.get('https://n8lk77uomc.execute-api.us-east-1.amazonaws.com/dev/comments/$pid');

  print ("response body");
  print (response.body);
  var body = json.decode(response.body);
  print (body);
  var list = body['result'] as List;
  print (list.map<Comment>((json) => Comment.fromJson(json)).toList());
  return list.map<Comment>((json) => Comment.fromJson(json)).toList();

}

Future<Comment> _makeCommentRequest(int uid, int pid, String context) async {
  // set up POST request arguments


  print ("HELLOOOOOO");
  print(context);
  String url = 'https://n8lk77uomc.execute-api.us-east-1.amazonaws.com/dev/comments';
  Map<String, String> headers = {"Content-type": "application/json"};
  String json = '{"uid": $uid, "pid": $pid, "context": "$context"}';
  final response = await post(url, headers: headers, body: json);
  int statusCode = response.statusCode;
  print ("COMMENT STATUS CODE");
  print (statusCode);
  print(json);
  Map<String, dynamic> map = convert.jsonDecode(response.body);
  Comment jsonResponse = Comment.fromJson(map['result']);


  if (statusCode == 200) {
    Map<String, dynamic> map = convert.jsonDecode(response.body);
    Comment jsonResponse = Comment.fromJson(map['result']);
    print ("RETURNING JSON RESPONSE");
    print (jsonResponse.cid);
    return jsonResponse;
  }

  if (statusCode == 400) {
    return Future.error(true);
  }

  return null;
}
