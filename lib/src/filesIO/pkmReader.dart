import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:android_path_provider/android_path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:DataMaker/src/pokemon/dataContainer.dart';
import 'package:DataMaker/src/pokemon/pokemon.dart';
import 'package:DataMaker/src/pokemon/pokemonUtils.dart';

Future<String> readStringEncoding(File f) async {
  String str;
  try {
    str = await f.readAsString();
  } catch (Exception) {
    str = await f.readAsString(encoding: latin1);
  }
  return str;
}

Future<Uint8List> getIconbytes(String gameFolder, int number) async {
  File iconFile = File(gameFolder +
      "/Graphics/Icons/icon${number.toString().padLeft(3, '0')}.png");
  var bytes;
  try {
    bytes = await iconFile.readAsBytes();
  } catch (Exception) {
    bytes =
        await File(gameFolder + "/Graphics/Icons/icon000.png").readAsBytes();
    print("No existe icono $number");
  }

  return bytes;
}

readMoves(String folderPath) async {
  File f = File(folderPath + "/PBS/moves.txt");
  String str = await readStringEncoding(f);
  List lines = LineSplitter.split(str).toList()
    ..removeWhere((element) => element.replaceAll("\n", "").isEmpty);
  DataContainer.pkmMoves = getMovesMap(lines);
  return DataContainer.pkmMoves;
}

readTms(String folderPath, List<Pokemon> pkm) async {
  File f = File(folderPath + "/PBS/tm.txt");
  String str = await readStringEncoding(f);
  List lines = LineSplitter.split(str).toList();
  return addTms(getTMs(lines), pkm);
}

readAbilities(String folderPath) async {
  File f = File(folderPath + "/PBS/abilities.txt");
  String str = await readStringEncoding(f);
  List lines = LineSplitter.split(str).toList();
  DataContainer.pkmAbilities = getAbilitiesMap(lines);
  return DataContainer.pkmAbilities;
}

readLocations(String folderPath) async {
  File f = File(folderPath + "/PBS/encounters.txt");
  String str = await readStringEncoding(f);
  DataContainer.pkmLocations =
      getLocationsMap(str.split(RegExp(r"(#+)")).sublist(1));
  return DataContainer.pkmLocations;
}

readTypes(folderPath) async {
  File f = File(folderPath + "/PBS/types.txt");
  String str = await readStringEncoding(f);
  DataContainer.pkmTypes = getTypesMap(str.split("["));
  return DataContainer.pkmTypes;
}

Future<List<Pokemon>> readPokemonFile(String gameFolder) async {
  List<Pokemon> pkm = [];
  File f = File(gameFolder + "/PBS/pokemon.txt");
  var str = await readStringEncoding(f);
  List l = str.split("[");
  l.removeAt(0);
  l.forEach((element) {
    pkm.add(getPokemon(element));
  });
  pkm = await readTms(gameFolder, pkm);
  pkm = addLocations(await readLocations(gameFolder), pkm);
  return await _addIcons(gameFolder, pkm);
}

Future<List<Pokemon>> _addIcons(String gameFolder, List<Pokemon> pkm) async {
  for (int i = 0; i < pkm.length; i++) {
    pkm[i].iconBytes = await getIconbytes(gameFolder, pkm[i].number);
  }
  return pkm;
}

readPokemonData(String path) async {
  String rawJson = await Pokemon.readPokemonJson(path);
  Map<String, dynamic> map = jsonDecode(rawJson);
  List<Pokemon> pkmData = [];

  map["Pokemon"].forEach((element) {
    pkmData.add(Pokemon.fromJson(element));
  });
  Map<String, List> pkmMoves = {},
      pkmAbilities = {},
      pkmLocations = {},
      pkmTypes = {};
  pkmMoves = map["Moves"].cast<String, List>();
  pkmAbilities = map["Abilities"].cast<String, List>();
  pkmLocations = map["Locations"].cast<String, List>();
  pkmTypes = map["Types"].cast<String, List>();
  DataContainer.pkmData = pkmData;
  DataContainer.pkmMoves = pkmMoves;
  DataContainer.pkmAbilities = pkmAbilities;
  DataContainer.pkmLocations = pkmLocations;
  DataContainer.pkmTypes = pkmTypes;
}

Future<String> getGamePath() async {
  String readPath;
  if (Platform.isAndroid) {
    if (await (Permission.storage.request()).isGranted) {
      readPath = await AndroidPathProvider.downloadsPath;
    }
  } else if (Platform.isWindows) {
    String user = Platform.environment["UserProfile"];
    readPath = "$user\\Downloads\\";
  } else {
    readPath = (await getDownloadsDirectory()).path;
  }
  return readPath;
}
