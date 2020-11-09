import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:DataMaker/src/pokemon/pokemon.dart';
import 'package:DataMaker/src/filesIO/pkmReader.dart';

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
  try {
    print("1");
    var pkm = await readPokemonFile(gameFolder);
    print("2");
    var moves = await readMoves(gameFolder);
    print("3");
    var abilities = await readAbilities(gameFolder);
    print("4");
    var locations = await readLocations(gameFolder);
    print("5");
    var types = await readTypes(gameFolder);
    print("6");
    await writePokemonJson(readPath, pkm, moves, abilities, locations, types);
  } catch (ex) {
    print(ex);
    print("ayuda");
  }
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
