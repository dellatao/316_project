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
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  final submitController = TextEditingController();

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

  void _removePostItem(bool banned, int index) {
    if (banned == true) {
      setState(() => _postItems.removeAt(index));
    }
  }

  _commentPressed(String title, int pid, String subtitle, String photoUrl){


    Navigator.push(context,
        MaterialPageRoute(builder:
            (context) => CommentsPage(todo: Todo(title, subtitle),
            pid: pid, user:widget.user, photo: photoUrl)
        )
    );
  }



  // Build the whole list of post items
  Widget _buildPostList() {

    return new FutureBuilder<List<Post>>(
        future: fetchPosts(http.Client(), widget.chid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {

            _addExistingItems(snapshot.data, widget.chid);
            _updateExistingItems(snapshot.data, widget.chid);
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

  void _updateExistingItems(final List<Post> posts, int num) {
    for (var p in posts) {
      if (p.chid == num) {

        int index = pids.indexOf(p.pid);

        flagCountList[index] = p.flags.length;
        likeCountList[index] = p.upVotes.length;
        dislikeCountList[index] = p.downVotes.length;


      }
    }
  }

  void _addExistingItems(final List<Post> posts, int num) {
    for (var p in posts) {
      if (p.chid == num) {

        if (! pids.contains(p.pid)) {
          if (p.upVotes.contains(widget.user.uid)){
            isLikedList.insert(0,true);
          }
          if (! p.upVotes.contains(widget.user.uid)){
            isLikedList.insert(0,false);
          }
          if (p.downVotes.contains(widget.user.uid)){
            isDislikedList.insert(0,true);
          }
          if (! p.downVotes.contains(widget.user.uid)){
            isDislikedList.insert(0,false);
          }
          if (p.flags.contains(widget.user.uid)){
            isFlaggedList.insert(0,true);
          }
          if (! p.flags.contains(widget.user.uid)){
            isFlaggedList.insert(0,false);
          }
          flagCountList.insert(0,p.flags.length);
          likeCountList.insert(0,p.upVotes.length);
          dislikeCountList.insert(0,p.downVotes.length);
          _postItems.insert(0,p.title);
          _subtitles.insert(0,p.detail);
          pids.insert(0,p.pid);
          photos.insert(0,p.photoUrl);
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
        photos[index] != null ? Image.network(photos[index]) : Container(constraints: BoxConstraints(maxWidth: 10, maxHeight: 10)),
        title: new Text(postText),
//        subtitle: new Text(author),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        trailing: Row(mainAxisSize: MainAxisSize.min,
          children: <Widget> [
            IconButton(icon: Icon(Icons.flag),  color: isFlagged ? Colors.redAccent:null, iconSize: 30, onPressed: () {
              setState(() {
              //_pressed(isPressed);
              Future<Flag> future = _makeFlagRequest(pids[index], widget.user.uid);
              future.then((value) => toggleCount(value.exists, isFlaggedList, index));
              future.then((value) => _removePostItem(value.banned, index));

              });
            }),
            Text(flagCountList[index].toString()),
            IconButton(icon: Icon(Icons.keyboard_arrow_up),  color: isLiked ? Colors.deepPurpleAccent:null, iconSize: 30, onPressed: () {
              Future<Vote> vote = _makeVoteRequest(pids[index], widget.user.uid, "upVote");
              setState(() {
                //_pressed(isPressed);
                vote.then((value) => toggleCount(value.isUpVote, isLikedList, index));
                vote.then((value) => toggleCount(value.isDownVote, isDislikedList, index));
                //vote.then((value) => toggleVoteCount(value.isUpVote, likeCountList, isLikedList, index));


              });
            }),

            Text(likeCountList[index].toString()),



            IconButton(icon: Icon(Icons.keyboard_arrow_down), color: isDisliked ? Colors.orangeAccent:null, iconSize: 30, onPressed: () {
              Future<Vote> vote = _makeVoteRequest(pids[index], widget.user.uid, "downVote");
              setState(() {
                vote.then((value) => toggleCount(value.isUpVote, isLikedList, index));
                vote.then((value) => toggleCount(value.isDownVote, isDislikedList, index));
                //vote.then((value) => toggleVoteCount(value.isDownVote, dislikeCountList, isDislikedList, index));
                //vote.then((value) => toggleCount(value.isUpVote, isLikedList, index));
              });
            }),
            Text(dislikeCountList[index].toString()),
          ],
        ),




        onTap: () => _commentPressed(postText, pid, subtitle, photos[index])
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


  void toggleCount(conditionBool, conditionList, index) {
    setState(() {
      if (conditionBool) {
        conditionList[index] = true;
      } else {
        conditionList[index] = false;
      }
    });
  }

  void toggleVoteCount(conditionBool, countList, conditionList, index) {
    setState(() {
      if (conditionBool) {
        countList[index] += 1;
        conditionList[index] = true;
      } else {
        countList[index] -= 1;
        conditionList[index] = false;
      }
    });
  }
  void authenicate(String title, String subtitle, String value) {
    Future<Post> psot = _makePostRequest(widget.chid, widget.user.uid, title, subtitle, value);
    psot.then((value) => _addPostItem(title, subtitle, value.pid, value.photoUrl));


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
                          style: style,
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
                          style:style,
//                        onSubmitted: (dval) {
//                          _addPostItem(dval);
//                        },
                          controller: subtitleController,

                          decoration: new InputDecoration(
                              hintText: 'Description',
                              contentPadding: const EdgeInsets.all(16.0)
                          ),
                        ),

                        SizedBox(
                            height: 40.0
                        ),
                        ButtonTheme(
                          minWidth:15.0,
                          height: 10.0,
                        child: Material(
                          elevation: 5.0,
                          borderRadius: BorderRadius.circular(20.0),
                          color: Colors.orangeAccent,
                          child: MaterialButton(
                            padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                            onPressed: () {
                              _choose();

                            },
                            child: Text("Choose Image",
                                textAlign: TextAlign.center,
                                style: style.copyWith(
                                    color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        ),

                        SizedBox(
                            height: 20.0
                        ),
                        ButtonTheme(
                            minWidth: 140.0,
                            height: 10.0,
                            child: Material(
                          elevation: 5.0,
                          borderRadius: BorderRadius.circular(20.0),
                          color: Colors.deepPurpleAccent,
                          child: MaterialButton(

                            padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                            onPressed: () {
                              String title = titleController.text;
                              String subtitle = subtitleController.text;
                              if (file != null){
                                Future<String> photo = _makePhotoRequest("photo$title", file);
                                photo.then((value) => authenicate(title, subtitle, value) );
                                setState(() {
                                  file = null;
                                });
                              }

                              else{
                                Future<Post> psot = _makePostRequest(widget.chid, widget.user.uid, title, subtitle, null);
                                psot.then((value) =>  _addPostItem(title, subtitle, value.pid, value.photoUrl));
                                Navigator.of(context).pop();
                                setState(() {

                                });
                              }
                              titleController.clear();
                              subtitleController.clear();

                            },
                            child: Text("Submit!",
                                textAlign: TextAlign.center,
                                style: style.copyWith(
                                    color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        ),

                        SizedBox(height: 60.0),
                            file == null
                            ? Text("No Image Selected",
                                textAlign: TextAlign.center,
                                style: style.copyWith(
                                    color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14.0))
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
  List<dynamic> upVotes;
  List <dynamic> downVotes;
  String deletedat;
  List <dynamic> flags;


  Post({this.pid, this.chid, this.uid, this.title, this.detail, this.photoUrl, this.upVotes, this.downVotes, this.flags, this.deletedat});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      pid: json['pid'],
      chid: json['chid'],
      uid:  json['uid'],
      title: json['title'],
      detail: json['detail'],
      photoUrl: json['photourl'],
      deletedat: json['deletedat'],
      upVotes: json['upVotes'] as List<dynamic>,
      downVotes: json['downVotes'] as List<dynamic>,
      flags: json['flags'] as List<dynamic>,
    );
  }
}



Future<List<Post>> fetchPosts(http.Client client, int chid) async {
  final response =
  await client.get('https://n8lk77uomc.execute-api.us-east-1.amazonaws.com/dev/posts/$chid');

  Map<String, dynamic> map = convert.jsonDecode(response.body);

  var list = map['results'] as List;
  int statusCode = response.statusCode;

  if (statusCode == 200){
//    Post jsonResponse = Post.fromJson(map['result']);
    return list.map<Post>((json) => Post.fromJson(json)).toList();
  }
  if (statusCode == 400){
    return null;
  }


}


Future<Post> _makePostRequest(int chid, int uid, String title, String detail, String photoUrl) async {
  // set up POST request arguments
  String url = 'https://n8lk77uomc.execute-api.us-east-1.amazonaws.com/dev/posts/';
  Map<String, String> headers = {"Content-type": "application/json"};
  String json = '{"chid": $chid, "uid": $uid, "title": "$title", "detail": "$detail", "photoUrl": "$photoUrl"}';
  final response = await post(url, headers: headers, body: json);
  int statusCode = response.statusCode;
  Map<String, dynamic> map = convert.jsonDecode(response.body);
  Post jsonResponse = Post.fromJson(map['result']);
  jsonResponse.chid = chid;
  jsonResponse.uid = uid;
  jsonResponse.title = title;
  jsonResponse.detail = detail;
  jsonResponse.photoUrl = photoUrl;
  jsonResponse.upVotes = [];
  jsonResponse.downVotes = [];
  jsonResponse.flags = [];
  jsonResponse.deletedat = null;
  return jsonResponse;

}



Future<String> _makePhotoRequest(String name, File data) async {
  // set up POST request arguments

  String base64Image = convert.base64Encode(data.readAsBytesSync());
  String url = 'https://n8lk77uomc.execute-api.us-east-1.amazonaws.com/dev/upload';
  Map<String, String> headers = {"Content-type": "application/json"};
  String json = '{"name": "$name", "data": "$base64Image"}';

  final response = await post(url, headers: headers, body: json);
  int statusCode = response.statusCode;

  Map<String, dynamic> map = convert.jsonDecode(response.body);
  String jsonResponse = map['result'].toString();

  return jsonResponse;

}

class Flag {
  bool exists;
  bool banned;


  Flag({this.exists, this.banned});

  factory Flag.fromJson(Map<String, dynamic> json) {
    return Flag(
      exists: json['exists'] as bool,
      banned: json['banned'] as bool,
    );
  }
}
Future<Flag> _makeFlagRequest(int pid, int uid) async {
  // set up POST request arguments

  String url = 'https://n8lk77uomc.execute-api.us-east-1.amazonaws.com/dev/posts/$pid/flag/$uid';
  Map<String, String> headers = {"Content-type": "application/json"};
  String json = '{"pid": $pid}';
  final response = await post(url, headers: headers, body: json);
  int statusCode = response.statusCode;


  Map<String, dynamic> map = convert.jsonDecode(response.body);
  Flag jsonResponse = Flag.fromJson(map['result']);

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

class Vote {
  bool isUpVote;
  bool isDownVote;


  Vote({this.isUpVote, this.isDownVote});

  factory Vote.fromJson(Map<String, dynamic> json) {
    return Vote(
      isUpVote: json['isUpVote'] as bool,
      isDownVote: json['isDownVote'] as bool,
    );
  }
}
Future<Vote> _makeVoteRequest(int pid, int uid, String voteType) async {
  // set up POST request arguments

  String url = 'https://n8lk77uomc.execute-api.us-east-1.amazonaws.com/dev/posts/$pid/$voteType/$uid';
  Map<String, String> headers = {"Content-type": "application/json"};
  final response = await post(url, headers: headers);
  int statusCode = response.statusCode;

  Map<String, dynamic> map = convert.jsonDecode(response.body);
  Vote jsonResponse = Vote.fromJson(map['result']);

  return jsonResponse;

}