import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(MaterialApp(
  home: Home(),
));

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _toDoController = TextEditingController();
  List _toDo = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To Do List'),
        backgroundColor: Colors.purple,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'New task',
                      labelStyle: TextStyle(color: Colors.purple),
                    ),
                    controller: _toDoController,
                  ),
                ),

                RaisedButton(
                  color: Colors.purple,
                  child: Text('ADD'),
                  textColor: Colors.white,
                  onPressed: _addToDoTask,
                )
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(top: 10.0),
              itemCount: _toDo.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text(_toDo[index]['title']),
                  value: _toDo[index]['ok'],
                  checkColor: Colors.green,
                  activeColor: Colors.transparent,
                  secondary: CircleAvatar(
                    foregroundColor: _toDo[index]['ok'] ? Colors.green : Colors.red,
                    child: Icon(
                      _toDo[index]['ok'] ? Icons.check : Icons.warning
                    ),
                  ),
                  onChanged: (c) {
                    setState(() {
                      _toDo[index]['ok'] = c;
                    });
                  },
                );
              },
            ),
          ),
        ],
      )
    );
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/data.json}');
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDo);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }

  void _addToDoTask() {
    setState(() {
      Map<String, dynamic> task = Map();
      task['title'] = _toDoController.text;
      task['ok'] = false;
      _toDoController.text = '';
      _toDo.add(task);
    });
  }
}
