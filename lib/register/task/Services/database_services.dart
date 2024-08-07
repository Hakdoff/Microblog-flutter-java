import 'dart:convert';

import 'package:flutter_java_crud/register/task/Services/globals.dart';
import 'package:flutter_java_crud/register/task/model/task.dart';
import 'package:http/http.dart' as http;

class DatabaseServices{

  static Future<Task> addTask(String title) async{
    Map data = {
      "title": title
    };
      var body = json.encode(data);
      var url = Uri.parse(baseURL + '/add');

      http.Response response = await http.post(
        url,
        headers: headers,
        body: body,
      );
      print(response.body);
      Map responseMap = jsonDecode(response.body);
      Task task = Task.fromMap(responseMap);

      return task;
  }

  static getTasks() {}
}