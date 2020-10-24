import 'package:DataMaker/src/gui/dataView.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:DataMaker/src/pokemon/pokemon.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:android_path_provider/android_path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);
  @override
  createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  List _lvItems = [];
  String writePath, version = "DataMaker 0.7.0";
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
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
              heroTag: "a",
              child: Icon(Icons.open_in_browser),
              tooltip: "New",
              onPressed: () => _createNew(context)),
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

  Widget _loadingCard() {
    return Card(
      child: Image.asset(
        "assets/loading.gif",
        height: 50,
        width: 50,
      ),
      elevation: 20,
      margin: const EdgeInsets.all(10),
      shadowColor: Colors.blue,
    );
  }

  Widget _makeCard(int index) {
    String name;
    if (Platform.isWindows) {
      name = _lvItems[index].split("\\").last;
    } else {
      name = _lvItems[index].split("/").last;
    }
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
    if (r.index == 0) {
      setState(() {
        File f = File(_lvItems[index]);
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
      File f = File(_lvItems[index]);
      if (l[0].length > 2) {
        f.renameSync(writePath + l[0]);
        setState(() {
          _lvItems[index] = writePath + l[0];
        });
      }
    }
  }

  _createNew(BuildContext context) async {
    String user = Platform.environment["UserProfile"];
    String gameFolder = await _pickDirectory(context, user);
    if (Platform.isWindows) {
      writePath = ("$user\\Documents\\Data\\");
    } else {
      writePath = (await getApplicationDocumentsDirectory()).path + "/Data/";
    }
    Directory data = Directory(writePath);
    if (!(await data.exists())) {
      await data.create();
    }

    if (gameFolder != null) {
      _cardNames.add(_getCardName("name"));
      _writeGameData(gameFolder);
    }
  }

  _writeGameData(gameFolder) async {
    var readPath;
    try {
      var pkm = await Pokemon.readPokemonFile(gameFolder);
      var moves = await Pokemon.readMoves(gameFolder);
      var abilities = await Pokemon.readAbilities(gameFolder);
      var locations = await Pokemon.readLocations(gameFolder);
      readPath = writePath + "${_getGameName(gameFolder)}";
      await Pokemon.writePokemonJson(
          readPath, pkm, moves, abilities, locations);
    } catch (ex) {
      print(ex);
      print("ayuda");
    }
    setState(() {
      _lvItems.add(readPath);
      var fut = _getCardName(readPath);
      _cardNames.last = fut;
    });
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

  Future<String> _pickDirectory(BuildContext context, String user) async {
    var gameFolder;
    Directory show;
    if (Platform.isAndroid) {
      if (await (Permission.storage.request()).isGranted) {
        show = Directory(await AndroidPathProvider.downloadsPath);
      }
    } else if (Platform.isWindows) {
      show = Directory("$user\\Downloads\\");
    } else {
      show = await getDownloadsDirectory();
    }
    gameFolder = await FilesystemPicker.open(
        context: context,
        rootDirectory: show,
        fsType: FilesystemType.folder,
        rootName: "Game folder",
        pickText: "Select");
    return gameFolder;
  }

  _refreshData() async {
    if (!Platform.isWindows) {
      writePath = (await getApplicationDocumentsDirectory()).path + "/Data/";
    } else {
      String user = Platform.environment["UserProfile"];
      writePath = ("$user\\Documents\\Data\\");
    }
    Directory data = Directory(writePath);
    if (!await (data.exists())) {
      await data.create();
    }
    _lvItems = [];
    var l = data.list();
    l.forEach((element) {
      setState(() {
        if (!_lvItems.contains(element.path)) {
          _lvItems.add(element.path);
          _cardNames.add(_getCardName(element.path));
        }
      });
    });
  }

  _readPokemonData(String path) async {
    String rawJson = await Pokemon.readPokemonJson(path);
    Map<String, dynamic> map = jsonDecode(rawJson);
    List<Pokemon> pkmData = [];

    map["Pokemon"].forEach((element) {
      pkmData.add(Pokemon.fromJson(element));
    });
    Map<String, List> pkmMoves = {}, pkmAbilities = {}, pkmLocations = {};
    pkmMoves = map["Moves"].cast<String, List>();
    pkmAbilities = map["Abilities"].cast<String, List>();
    pkmLocations = map["Locations"].cast<String, List>();
    DataContainer.pkmData = pkmData;
    DataContainer.pkmMoves = pkmMoves;
    DataContainer.pkmAbilities = pkmAbilities;
    DataContainer.pkmLocations = pkmLocations;
  }

  _openCard(BuildContext context, String path) async {
    await _readPokemonData(path);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => DataView(path)));
  }
}
