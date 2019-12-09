import 'dart:io' as prefix0;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'comments.dart';
import 'dart:convert' as convert;
import 'user.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

File file;
class PostList extends StatefulWidget {
  @override
  createState() => new PostListState();

  final int chid;
  final User user;
  const PostList({Key key, @required this.chid, @required this.user}) : super(key: key);
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
  List<int> pids = [];
  List<String> photos = [];
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
    post = fetchPosts(http.Client(), widget.chid);
  }


  void _addPostItem(String task, String subtitle, int pid, String imageUrl) {
    if(task.length > 0) {
      _postItems.insert(0, task);
      _subtitles.insert(0,subtitle);
      isFlaggedList.insert(0, false);
      isLikedList.insert(0, false);
      isDislikedList.insert(0, false);
      flagCountList.insert(0, 0);
      likeCountList.insert(0, 0);
      dislikeCountList.insert(0, 0);
      pids.insert(0, pid);
      photos.insert(0, imageUrl);
    }
  }

  void _removePostItem(int index) {
    setState(() => _postItems.removeAt(index));
  }

  _commentPressed(String title, int pid, String subtitle){

    print(pid);

    Navigator.push(context,
        MaterialPageRoute(builder:
            (context) => CommentsPage(todo: Todo(title, subtitle),
            pid: pid, user:widget.user)
        )
    );
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
    return new FutureBuilder<List<Post>>(
        future: fetchPosts(http.Client(), widget.chid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _addExistingItems(snapshot.data, widget.chid);
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          return new ListView.builder(
            itemBuilder: (context, index) {
              // itemBuilder will be automatically be called as many times as it takes for the
              // list to fill up its available space
              if (index < _postItems.length) {
                return _buildPostItem(_postItems[index], _subtitles[index], pids[index], index);
              }
              return null;
            },
          );
        }
    );
  }

  void _addExistingItems(final List<Post> posts, int num) {
    for (var p in posts) {
      if (p.chid == num) {
        if (! pids.contains(p.pid)) {
          _postItems.add(p.title);
          isFlaggedList.add(false);
          isLikedList.add(false);
          isDislikedList.add(false);
          flagCountList.add(p.flag);
          likeCountList.add(p.upvote);
          dislikeCountList.add(p.downvote);
          _subtitles.add(p.detail);
          pids.add(p.pid);
          photos.add(p.photoUrl);
        }
      }
    }
  }

  // Build a single  item
  Widget _buildPostItem(String postText, String subtitle, int pid, int index) {
    bool isFlagged = isFlaggedList[index];
    bool isLiked = isLikedList[index];
    bool isDisliked = isDislikedList[index];
    int flagCount = flagCountList[index];
    int likeCount = likeCountList[index];
    int dislikeCount = dislikeCountList[index];

    return new ListTile(
        leading:
        photos[index] != null ? Image.network(photos[index]) : Container(constraints: BoxConstraints(maxWidth: 20, maxHeight: 20)),
        title: new Text(postText),
//        subtitle: new Text(author),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        trailing: Row(mainAxisSize: MainAxisSize.min,
          children: <Widget> [
            IconButton(icon: Icon(Icons.flag),  color: isFlagged ? Colors.redAccent:null, iconSize: 30, onPressed: () {
              //setState(() {
              //_pressed(isPressed);
              Future<Flag> future = _makeFlagRequest(pids[index]);
              future.then((value) => toggleCount(isFlagged, flagCountList, isFlaggedList, index));

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




        onTap: () => _commentPressed(postText, pid, subtitle)
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
  void authenicate(Post value) {
    _makePhotoRequest("photo", file, value.pid);
    _addPostItem(titleController.text, subtitleController.text, value.pid, value.photoUrl);

    print ("THIS WAS ADDED");
    Navigator.of(context).pop();
    //Navigator.push(
        //context,
        //MaterialPageRoute(builder: (context) => VortexApp(user: widget.user)));
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
                        RaisedButton(
                          onPressed: _choose,
                          child: Text('Choose Image'),
                        ),
                        SizedBox(width: 10.0),
                        RaisedButton(
                          onPressed: _upload,
                          child: Text('Upload Image'),
                        ),
                        FlatButton(
                            child: Text('Submit'),
                            onPressed: () {
                              Future<Post> psot = _makePostRequest(widget.chid, widget.user.uid, titleController.text, subtitleController.text, null);
                              psot.then((value) => authenicate(value));

                              titleController.clear();
                              subtitleController.clear();

                            }
                        ),
                            file == null
                            ? Text('No Image Selected')
                            : Image.file(file)
                      ]
                  ),

              );
            }
        )
    );
  }
}

class Post {
  int pid;
  int chid;
  int uid;
  String title;
  String detail;
  String photoUrl;
  int upvote;
  int downvote;
  int flag;


  Post({this.pid, this.chid, this.uid, this.title, this.detail, this.photoUrl, this.upvote, this.downvote, this.flag});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      pid: json['pid'] as int,
      chid: json['chid'] as int,
      uid:  json['uid'] as int,
      title: json['title'] as String,
      detail: json['detail'] as String,
      photoUrl: json['photoUrl'] as String,
      upvote: json['upvote'] as int,
      downvote: json['downvote'] as int,
      flag: json['flag'] as int,
    );
  }
}

Future<List<Post>> fetchPosts(http.Client client, int chid) async {
  final response =
  await client.get('https://n8lk77uomc.execute-api.us-east-1.amazonaws.com/dev/posts/$chid');
  Map<String, dynamic> map = convert.jsonDecode(response.body);
  var list = map['result'] as List;
  return list.map<Post>((json) => Post.fromJson(json)).toList();

}


Future<Post> _makePostRequest(int chid, int uid, String title, String detail, String photoUrl) async {
  // set up POST request arguments
  String url = 'https://n8lk77uomc.execute-api.us-east-1.amazonaws.com/dev/posts/';
  Map<String, String> headers = {"Content-type": "application/json"};
  String json = '{"chid": $chid, "uid": $uid, "title": "$title", "detail": "$detail", "photoUrl": "$photoUrl"}';
  final response = await post(url, headers: headers, body: json);
  int statusCode = response.statusCode;
  print (statusCode);
  print(uid);

  Map<String, dynamic> map = convert.jsonDecode(response.body);
  Post jsonResponse = Post.fromJson(map['result']);
  print(jsonResponse.pid);
  jsonResponse.chid = chid;
  jsonResponse.uid = uid;
  jsonResponse.title = title;
  jsonResponse.detail = detail;
  jsonResponse.photoUrl = photoUrl;
  jsonResponse.upvote = 0;
  jsonResponse.downvote = 0;
  jsonResponse.flag = 0;

  print(jsonResponse.chid);
  return jsonResponse;

}



Future<String> _makePhotoRequest(String name, File data, int pid) async {
  // set up POST request arguments
  print("soju");
  String base64Image = convert.base64Encode(data.readAsBytesSync());
  print("hey");
  print(base64Image);
  String url = 'https://n8lk77uomc.execute-api.us-east-1.amazonaws.com/dev/posts/$pid/upload';
  Map<String, String> headers = {"Content-type": "application/json"};
  String json = '{"name": "$name", "data": "$base64Image"}';

  print("json");
  print(json);
  final response = await post(url, headers: headers, body: json);
  int statusCode = response.statusCode;
  print (statusCode);
  print ("RESPONSE BODY FOR PHOTOS");
  print (response.body);

  String map = convert.jsonDecode(response.body);

  print ("MAP");
  print (map);
  return map.toString();

}

class Flag {
  int newFlag;
  bool banned;


  Flag({this.newFlag, this.banned});

  factory Flag.fromJson(Map<String, dynamic> json) {
    return Flag(
      newFlag: json['newFlag'] as int,
      banned: json['banned'] as bool,
    );
  }
}
Future<Flag> _makeFlagRequest(int pid) async {
  // set up POST request arguments
  String url = 'https://n8lk77uomc.execute-api.us-east-1.amazonaws.com/dev/posts/$pid/flag';
  Map<String, String> headers = {"Content-type": "application/json"};
  String json = '{"pid": $pid}';
  final response = await post(url, headers: headers, body: json);
  int statusCode = response.statusCode;
  print ("STATUS CODE FALG");
  print (statusCode);


  Map<String, dynamic> map = convert.jsonDecode(response.body);
  Flag jsonResponse = Flag.fromJson(map['result']);



  print(jsonResponse.newFlag);
  return jsonResponse;

}

void _choose() async {
  file = await ImagePicker.pickImage(source: ImageSource.gallery);
// file = await ImagePicker.pickImage(source: ImageSource.gallery);
}

void _upload() {
  if (file == null) return;
  String base64Image = convert.base64Encode(file.readAsBytesSync());
  String fileName = file.path.split("/").last;
}