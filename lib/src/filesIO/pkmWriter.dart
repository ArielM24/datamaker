import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:DataMaker/src/pokemon/pokemon.dart';
import 'package:DataMaker/src/filesIO/pkmReader.dart';

Future writePokemonJson(String path, List<Pokemon> pkm, Map<String, List> moves,
    abilities, locations) async {
  File fout = File(path);
  await fout.create(recursive: true);
  Map<String, dynamic> mpkm = {
    "Pokemon": pkm,
    "Moves": moves,
    "Abilities": abilities,
    "Locations": locations
  };
  String rawJson = jsonEncode(mpkm);
  await fout.writeAsString(rawJson);
}

writeGameData(gameFolder, readPath) async {
  try {
    var pkm = await readPokemonFile(gameFolder);
    var moves = await readMoves(gameFolder);
    var abilities = await readAbilities(gameFolder);
    var locations = await readLocations(gameFolder);
    await writePokemonJson(readPath, pkm, moves, abilities, locations);
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
