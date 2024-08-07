import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class TaskService {
  Future<http.Response> saveTask(
    String title, String description, bool done
  ) async {
    var uri = Uri.parse("http://localhost:8080/tasks/add");

    Map<String, String> headers = {"Content-Type": "application/json"};

    Map data = {
      'title': '$title',
      'description': '$description',
      'done': done
    };

    var body = json.encode(data);
    var response = await http.post(uri, headers: headers, body: body);

    print("${response.body}");
    return response;
  }
}