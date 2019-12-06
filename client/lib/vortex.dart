import 'package:flutter/material.dart';
import 'postlist.dart';

class VortexApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return new MaterialApp(
      title: 'Welcome to the Vortex',
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: new Color(0xFF131515),
            bottom: TabBar(

              tabs: [
                Tab(icon: new Image.asset("assets/images/Group3.png")),
                Tab(icon: Icon(Icons.people_outline)),
                Tab(icon: Icon(Icons.restaurant)),
                Tab(icon: Icon(Icons.local_taxi)),

              ],
            ),
            title: Text('Welcome to the Vortex'),
          ),
          body: TabBarView(
            children: [
              new PostList(),
              new PostList(),
              new PostList(),
              new PostList(),
            ],
          ),
        ),
      ),
    );
  }
}
