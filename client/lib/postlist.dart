import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'dart:async';
import 'comments.dart';
import 'dart:convert';

class PostList extends StatefulWidget {
  @override
  createState() => new PostListState();
}


class PostListState extends State<PostList> with AutomaticKeepAliveClientMixin<PostList>{
  List<String> _postItems = [];
  bool get wantKeepAlive => true;
  List<bool> isFlaggedList = [];
  List<bool>isLikedList = [];
  List<bool>isDislikedList = [];
  List<int>flagCountList = [];
  List<int>likeCountList = [];
  List<int>dislikeCountList = [];
  Future<List<Post>> post;
//  List<String> _authors = [];
  List<String> _subtitles = [];
  final titleController = TextEditingController();
  final subtitleController = TextEditingController();

  void dispose() {
    // Clean up the controller when the widget is disposed.
    titleController.dispose();
    subtitleController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    post = fetchPost();
  }


  void _addPostItem(String task, String subtitle) {
    if(task.length > 0) {
      _postItems.insert(0, task);
      isFlaggedList.insert(0, false);
      isLikedList.insert(0, false);
      isDislikedList.insert(0, false);
      flagCountList.insert(0, 0);
      likeCountList.insert(0, 0);
      dislikeCountList.insert(0, 0);
//      _authors.insert(0, author);
      _subtitles.insert(0,subtitle);
    }
  }

  void _removePostItem(int index) {
    setState(() => _postItems.removeAt(index));
  }

  _commentPressed(String title, String subtitle){
    setState(() {
      Navigator.push(context, MaterialPageRoute(builder: (context) => CommentsPage(todo: Todo(title, subtitle))));
    });
  }

  void _promptFlagPost(int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
              title: new Text('Flag "${_postItems[index]}" as inappropriate?'),
              actions: <Widget>[
                new FlatButton(
                    child: new Text('CANCEL'),
                    // The alert is actually part of the navigation stack, so to close it, we
                    // need to pop it.
                    onPressed: () => Navigator.of(context).pop()
                ),
                new FlatButton(
                    child: new Text('FLAG POST'),
                    onPressed: () {
                      _removePostItem(index);
                      Navigator.of(context).pop();
                    }
                )
              ]
          );
        }
    );
  }

  // Build the whole list of post items
  Widget _buildPostList() {
    return FutureBuilder<List<Post>>(
        future: fetchPost(),
        builder: (context, snapshot) {

          if (snapshot.hasData) {
            List<Post> posts = snapshot.data;
            return new Column(
                children: posts.map((post) =>
                new Column(
                  children: <Widget>[
                    new Text(post.title),
                    new Text(post.body),
                  ],
                )).toList()
            );
          }
          else if(snapshot.hasError) {
            return snapshot.error;
          }
          return new ListView.builder(
            itemBuilder: (context, index) {
              // itemBuilder will be automatically be called as many times as it takes for the
              // list to fill up its available space
              if (index < _postItems.length) {
                return _buildPostItem(_postItems[index], _subtitles[index], index);
              }
              return null;
            },
          );
        }
    );
  }

  // Build a single  item
  Widget _buildPostItem(String postText, String subtitle, int index) {
    bool isFlagged = isFlaggedList[index];
    bool isLiked = isLikedList[index];
    bool isDisliked = isDislikedList[index];
    int flagCount = flagCountList[index];
    int likeCount = likeCountList[index];
    int dislikeCount = dislikeCountList[index];

    return new ListTile(
        leading: new Image.asset("assets/images/Group3.png"),
        title: new Text(postText),
//        subtitle: new Text(author),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        trailing: Row(mainAxisSize: MainAxisSize.min,
          children: <Widget> [
            IconButton(icon: Icon(Icons.flag),  color: isFlagged ? Colors.redAccent:null, iconSize: 30, onPressed: () {
              setState(() {
                //_pressed(isPressed);
                toggleCount(isFlagged, flagCountList, isFlaggedList, index);
                _promptFlagPost(index);

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



        onTap: () => _commentPressed(postText, subtitle)
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return new Scaffold(
//      appBar: new AppBar(
//          title: new Text('Vortex Feed'),
//          backgroundColor: new Color(0xFF7646FF)
//      ),
      body: _buildPostList(),
      floatingActionButton: new FloatingActionButton(
          heroTag: null,
          onPressed: _pushAddPostScreen,
          tooltip: 'Add Post',
          child: new Icon(Icons.add),
          backgroundColor: Color(0xFFFFAE34)
      ),
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

  void _pushAddPostScreen() {
    // Push this page onto the stack
    Navigator.of(context).push(
      // MaterialPageRoute will automatically animate the screen entry, as well as adding
      // a back button to close it
        new MaterialPageRoute(
            builder: (context) {
              return new Scaffold(
                  appBar: new AppBar(
                    title: new Text('Add New Post'),
                    backgroundColor: Color(0xFF131515),
                  ),
                  body: new Column(
                      children: <Widget>[
                        new TextField(
                          autofocus: true,
//                        onSubmitted: (val) {
//                          _addPostItem(val);
//                        },
                          controller: titleController,
                          decoration: new InputDecoration(
                              hintText: 'Title',
                              contentPadding: const EdgeInsets.all(16.0)
                          ),
                        ),
                        new TextField(
                          autofocus: true,
//                        onSubmitted: (dval) {
//                          _addPostItem(dval);
//                        },
                          controller: subtitleController,
                          decoration: new InputDecoration(
                              hintText: 'Description',
                              contentPadding: const EdgeInsets.all(16.0)
                          ),
                        ),
                        FlatButton(
                            child: Text('Submit'),
                            onPressed: () {
                              _addPostItem(titleController.text, subtitleController.text);
                              titleController.clear();
                              subtitleController.clear();
                              Navigator.pop(context);
                            }
                        ),
                      ]
                  )
              );
            }
        )
    );
  }
}

class Post {
  final int pid;
  final int chid;
  final int uid;
  final String title;
  final String body;
  final int upvote;
  final int downvote;
  final int flag;
  final DateTime deletedat;
  final String username;

  Post({this.pid, this.chid, this.uid, this.body, this.deletedat, this.downvote,
    this.flag, this.title, this.upvote, this.username});

  factory Post.fromJson(Map<String, dynamic> json) {
    return new Post(
        uid: json['uid'],
        pid: json['pid'],
        chid: json['chid'],
        title: json['title'],
        body: json['body'],
        upvote: json['upVote'],
        downvote: json['downVote'],
        flag: json['flag'],
        deletedat: json['deletedAt'],
        username: json['username']
    );
  }
}

Future<List<Post>> fetchPost() async {
  http.Response response = await http.get(
      'https://jsonplaceholder.typicode.com/posts');
  var responseJson = json.decode(response.body);
  return (responseJson as List)
      .map((p) => Post.fromJson(p))
      .toList();
}
