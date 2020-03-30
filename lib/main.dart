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
  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPosition;

  @override
  void initState() {
    super.initState();

    _readData().then((onValue) {
      setState(() {
        _toDo = json.decode(onValue);
      });
    });
  }

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
              itemBuilder: buildItem,
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
      _saveData();
    });
  }

  Widget buildItem(BuildContext context, int index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(Icons.delete, color: Colors.white,),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
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
            _saveData();
          });
        },
      ),
      onDismissed: (direction) {
        setState(() {
          _lastRemoved = Map.from(_toDo[index]);
          _lastRemovedPosition = index;
          _toDo.removeAt(index);

          _saveData();

          final snackBar = undoRemoved();

          Scaffold.of(context).showSnackBar(snackBar);
        });
      },
    );
  }

  SnackBar undoRemoved() {
    return SnackBar(
      content: Text('Removed "${_lastRemoved["title"]}" task'),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          setState(() {
            _toDo.insert(_lastRemovedPosition, _lastRemoved);
            _saveData();
          });
        },
      ),
      duration: Duration(seconds: 2),
    );
  }
}
