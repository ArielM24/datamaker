import 'dart:io';
import 'package:flutter/material.dart';
import 'package:DataMaker/src/gui/dataView.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:DataMaker/src/filesIO/pkmReader.dart';
import 'package:DataMaker/src/filesIO/pkmWriter.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);
  @override
  createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  List _lvItems = [];
  String writePath, version = "DataMaker 0.8.1";
  bool started = false;
  List<Future> _cardNames = [];
  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(version),
        leading: Padding(
            padding: const EdgeInsets.all(8),
            child: Image.asset("assets/pokemon-go.png")),
      ),
      body: Center(
        child: Scrollbar(
          child: ListView.builder(
            itemCount: _lvItems.length,
            itemBuilder: (context, int index) {
              return FutureBuilder(
                future: _cardNames[index],
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return _makeCard(index);
                  } else {
                    return _loadingCard();
                  }
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
              heroTag: "a",
              child: Icon(Icons.open_in_browser),
              tooltip: "New from game folder",
              onPressed: () => _createNew(context)),
          SizedBox(
            width: 10,
          ),
          FloatingActionButton(
              heroTag: "b",
              child: Icon(Icons.open_in_browser),
              tooltip: "New from file",
              onPressed: () => _newFromFile(context)),
          SizedBox(
            width: 10,
          ),
          FloatingActionButton(
              heroTag: "c",
              child: Icon(Icons.refresh),
              tooltip: "Refresh",
              onPressed: _refreshData),
        ],
      ),
    );
  }

  Widget _loadingCard() {
    return Card(
      child: Center(child: CircularProgressIndicator()),
      elevation: 20,
      margin: const EdgeInsets.all(10),
      shadowColor: Colors.blue,
    );
  }

  Widget _makeCard(int index) {
    String name = _getGameName(_lvItems[index]);
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.insert_drive_file,
              color: Colors.blue,
            ),
            title: Text("$name"),
            onTap: () {
              _openCard(context, _lvItems[index]);
            },
          ),
          Row(
            children: [
              FlatButton(
                  onPressed: () {
                    _renameCard(context, index);
                  },
                  child: Text("Renombrar")),
              FlatButton(
                  onPressed: () {
                    _deleteCard(context, index);
                  },
                  child: Text("Borrar")),
              FlatButton(
                  onPressed: () {
                    _copyCard(context, index);
                  },
                  child: Text("Copiar"))
            ],
          )
        ],
      ),
      elevation: 20,
      margin: const EdgeInsets.all(10),
      shadowColor: Colors.blue,
    );
  }

  _copyCard(BuildContext context, int index) async {
    var path = await _pickDirectory(context, "Copy to", "Copy");
    File copyTo = File(path + "/" + _getGameName(_lvItems[index]) + ".dmjson");
    copyTo.create();
    print(copyTo.path);
    File data = File(_lvItems[index] + ".dmjson");
    data.readAsString().then((value) => copyTo.writeAsString(value));
    showAlertDialog(context: context, message: "Copied at: ${copyTo.path}");
  }

  _deleteCard(BuildContext context, int index) async {
    var r =
        await showOkCancelAlertDialog(context: context, message: "¿Borrar?");
    if (r.index == 0) {
      setState(() {
        File f = File(_lvItems[index] + ".dmjson");
        f.delete();
        _lvItems.removeAt(index);
        _cardNames.removeAt(index);
      });
    }
  }

  _renameCard(BuildContext context, int index) async {
    var l = await showTextInputDialog(
        context: context,
        textFields: [DialogTextField()],
        barrierDismissible: false);
    if (l != null) {
      writePath = await getDataPath();
      File f = File(_lvItems[index] + ".dmjson");
      if (l[0].length > 2) {
        f.renameSync(writePath + l[0] + ".dmjson");
        setState(() {
          _lvItems[index] = writePath + l[0];
        });
      }
    }
  }

  _newFromFile(BuildContext context) async {
    String filePath = await _pickFile(context);
    print(filePath);
    File file = File(filePath);

    String name = _getGameName(filePath);
    writePath = (await getDataPath()) + "/" + name;
    File data = File(writePath);
    data.create();
    file.readAsString().then((value) => data.writeAsString(value));
    _cardNames.add(_getCardName("name"));
    setState(() {
      _lvItems.add(data.path.substring(0, data.path.length - 7));
    });
    return true;
  }

  _createNew(BuildContext context) async {
    String gameFolder = await _pickDirectory(context);
    String writePath = await getDataPath();
    Directory data = Directory(writePath);
    if (!(await data.exists())) {
      await data.create();
    }
    String readPath = writePath + "${_getGameName(gameFolder)}";
    if (gameFolder != null) {
      _cardNames.add(_getCardName("name"));
      writeGameData(gameFolder, readPath);
      setState(() {
        _lvItems.add(readPath);
        var fut = _getCardName(readPath);
        _cardNames.last = fut;
      });
    }
    return true;
  }

  String _getGameName(gameFolder) {
    String name;
    if (Platform.isWindows) {
      name = gameFolder.split("\\").last;
    } else {
      name = gameFolder.split("/").last;
    }
    return name;
  }

  Future<String> _getCardName(String name) async {
    await Future.delayed(Duration(seconds: 2));
    return name;
  }

  Future<String> _pickFile(BuildContext context) async {
    var filePath;
    filePath = await FilesystemPicker.open(
        context: context,
        rootDirectory: Directory(await getGamePath()),
        fsType: FilesystemType.file,
        allowedExtensions: [".dmjson"]);
    return filePath;
  }

  Future<String> _pickDirectory(BuildContext context,
      [String rootName = "Game folder",
      String pickText = "select",
      Directory directory]) async {
    var gameFolder;
    Directory show;
    if (directory == null)
      show = Directory(await getGamePath());
    else
      show = directory;
    gameFolder = await FilesystemPicker.open(
        context: context,
        rootDirectory: show,
        fsType: FilesystemType.folder,
        rootName: rootName,
        pickText: pickText);
    return gameFolder;
  }

  _refreshData() async {
    String dataPath = await getDataPath();
    Directory data = Directory(dataPath);
    if (!await (data.exists())) {
      await data.create();
    }
    _lvItems = [];
    var l = data.list();
    l.forEach((element) {
      setState(() {
        if (!_lvItems.contains(element.path)) {
          _lvItems.add(element.path.substring(0, element.path.length - 7));
          _cardNames.add(_getCardName(element.path));
        }
      });
    });
  }

  _openCard(BuildContext context, String path) async {
    await readPokemonData(path + ".dmjson");
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => DataView(path)));
  }
}
