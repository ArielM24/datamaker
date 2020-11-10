import 'dart:io';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:DataMaker/src/pokemon/pokemon.dart';
import 'package:DataMaker/src/filesIO/pkmReader.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';

Future writePokemonJson(String path, List<Pokemon> pkm, Map<String, List> moves,
    abilities, locations, types) async {
  File fout = File(path + ".dmjson");
  await fout.create(recursive: true);
  Map<String, dynamic> mpkm = {
    "Pokemon": pkm,
    "Moves": moves,
    "Abilities": abilities,
    "Locations": locations,
    "Types": types
  };
  String rawJson = jsonEncode(mpkm);
  await fout.writeAsString(rawJson);
}

writeGameData(gameFolder, readPath) async {
  var pkm, moves, abilities, locations, types;
  try {
    pkm = await readPokemonFile(gameFolder);
  } catch (Exception) {
    return 1;
  }
  try {
    moves = await readMoves(gameFolder);
  } catch (Exception) {
    return 2;
  }
  try {
    abilities = await readAbilities(gameFolder);
  } catch (Exception) {
    return 3;
  }
  try {
    locations = await readLocations(gameFolder);
  } catch (Exception) {
    return 4;
  }
  try {
    types = await readTypes(gameFolder);
  } catch (Exception) {
    return 5;
  }

  try {
    await writePokemonJson(readPath, pkm, moves, abilities, locations, types);
  } catch (ex) {
    print(ex);
    return 6;
  }
  return 0;
}

Future<String> getDataPath() async {
  String writePath;
  if (Platform.isWindows) {
    String user = Platform.environment["UserProfile"];
    writePath = ("$user\\Documents\\Data\\");
  } else {
    writePath = (await getApplicationDocumentsDirectory()).path + "/Data/";
  }
  return writePath;
}
