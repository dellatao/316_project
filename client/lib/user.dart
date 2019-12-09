import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert' as convert;




class User {
  final int uid;
  final String phonenumber;
  final String password;
  final String username;
  final String deletedat;
  final int clout;

  User({this.uid, this.phonenumber, this.password, this.username, this.deletedat,
    this.clout});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        uid: json['uid'],
        phonenumber: json['phonenumber'],
        password: json['password'],
        username: json['username'],
        deletedat: json['deletedat'],
        clout: json['clout']
    );
  }
}

Future<User> fetchUser(http.Client client, username, password) async {
  final String url = 'https://n8lk77uomc.execute-api.us-east-1.amazonaws.com/dev/login';
  Map<String, String> headers = {"Content-Type": "application/json"};
  String json = '{"id": "$username", "password": "$password"}';
  // make post request
  final response = await client.post(url, headers: headers, body: json);

  // check the status code for the result
  int statusCode = response.statusCode;

//  print(headers);
//  print(json);
//  print(statusCode);

  if (statusCode == 200)
  {
    Map<String, dynamic> map = convert.jsonDecode(response.body);
    User person = User.fromJson(map['result']);
    if (person.deletedat == null)
      return person;
  }

  if (statusCode == 400)
  {
    return Future.error(true);
  }

  return null;

}
Future<User> fetchNewUser(http.Client client, String username, String password, String phone) async {
  // set up post request arguments
  final String url = 'https://n8lk77uomc.execute-api.us-east-1.amazonaws.com/dev/users';
  Map<String, String> headers = {"Content-Type": "application/json"};
  String json = '{"username": "$username", "phoneNumber": "$phone", "password": "$password", "clout": 0}';
  // make post request
  final response = await client.post(url, headers: headers, body: json);

  // check the status code for the result
  int statusCode = response.statusCode;

  if (statusCode == 200) {
    Map<String, dynamic> map = convert.jsonDecode(response.body);
    User person = User.fromJson(map['result']);
    if (person.deletedat == null) return person;
  }

  if (statusCode == 400) {
    return Future.error(true);
  }

  return null;
}