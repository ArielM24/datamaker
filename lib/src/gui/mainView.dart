import 'package:DataMaker/src/gui/dataView.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:DataMaker/src/pokemon/pokemon.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'dart:convert';

class homePage extends StatefulWidget {
  homePage({Key key}) : super(key: key);
  @override
  createState() => _homePage();
}

class _homePage extends State<homePage> {
  List<String> _lvItems = [];
  String dir;
  bool started = false;
  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("DataMaker"),
        leading: Padding(
            padding: const EdgeInsets.all(8),
            child: Image.asset("assets/pokemon-go.png")),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: _lvItems.length,
          itemBuilder: (context, int index) {
            return _makeCard(index);
          },
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
              heroTag: "a",
              child: Icon(Icons.open_in_browser),
              tooltip: "New",
              onPressed: _createNew),
          SizedBox(
            width: 10,
          ),
          FloatingActionButton(
              heroTag: "b",
              child: Icon(Icons.refresh),
              tooltip: "Refresh",
              onPressed: _refreshData),
        ],
      ),
    );
  }

  Widget _makeCard(int index) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.insert_drive_file,
              color: Colors.blue,
            ),
            title: Text("${_lvItems[index].split("/").last}"),
            onTap: () {
              _openCard(context, _lvItems[index]);
            },
          ),
          Row(
            children: [
              FlatButton(
                  onPressed: () {
                    //f.rename(newPath)
                    _renameCard(context, index);
                  },
                  child: Text("Renombrar")),
              FlatButton(
                  onPressed: () {
                    _deleteCard(context, index);
                  },
                  child: Text("Borrar"))
            ],
          )
        ],
      ),
      elevation: 20,
      margin: const EdgeInsets.all(10),
      shadowColor: Colors.blue,
    );
  }

  _deleteCard(BuildContext context, int index) async {
    var r =
        await showOkCancelAlertDialog(context: context, message: "¿Borrar?");
    print(r.index);
    if (r.index == 0) {
      setState(() {
        File f = File(_lvItems[index]);
        f.delete();
        _lvItems.removeAt(index);
      });
    }
  }

  _renameCard(BuildContext context, int index) async {
    var l = await showTextInputDialog(
        context: context,
        textFields: [DialogTextField()],
        barrierDismissible: false);
    if (l != null) {
      File f = File(_lvItems[index]);
      if (l[0].length > 2) {
        f.renameSync(dir + "/Data/" + l[0]);
        setState(() {
          _lvItems[index] = dir + "/Data/" + l[0];
        });
      }
    }
  }

  _createNew() async {
    var res = await FilePickerCross.importFromStorage(
        type: FileTypeCross.custom, fileExtension: "txt");

    dir = (await getApplicationDocumentsDirectory()).path;
    var fpath;
    if (res != null) {
      try {
        var pkm = await Pokemon.readPokemonFile(res.path);
        fpath = dir + "/Data/data${_lvItems.length}";
        await Pokemon.writePokemonJson(fpath, pkm);
        //await Pokemon.readPokemonJson(dir + "/Data/data${_lvItems.length}.txt");
      } catch (ex) {
        print(ex);
        print("ayuda");
      }
      setState(() {
        _lvItems.add(fpath);
      });
    }
  }

  _readData() async {
    Directory d = Directory(dir + "/Data");
    var l = d.list();
    l.forEach((element) {
      print(element.path);
      setState(() {
        _lvItems.add(element.path);
      });
    });
  }

  _refreshData() async {
    dir = (await getApplicationDocumentsDirectory()).path;
    Directory d = Directory(dir + "/Data");
    if (!await (d.exists())) {
      await d.create();
    }
    var l = d.list();
    l.forEach((element) {
      setState(() {
        if (!_lvItems.contains(element.path)) {
          _lvItems.add(element.path);
        }
      });
    });
  }

  _readPokemonData(String path) async {
    String rawJson = await Pokemon.readPokemonJson(path);
    Map<String, dynamic> map = jsonDecode(rawJson);
    List<Pokemon> res = [];
    map["Pokemon"].forEach((element) {
      res.add(Pokemon.fromJson(element));
    });
    return res;
  }

  _openCard(BuildContext context, String path) async {
    List<Pokemon> pkm = await _readPokemonData(path);
    dataContainer.pkmData = pkm;
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => dataView(path)));
  }
}
