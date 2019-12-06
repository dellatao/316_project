import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';


class User {
  final int uid;
  final String phonenumber;
  final String password;
  final String username;

  User({this.uid, this.phonenumber, this.password, this.username});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        uid: json['uid'],
        phonenumber: json['phonenumber'],
        password: json['password'],
        username: json['username']
    );
  }
}
