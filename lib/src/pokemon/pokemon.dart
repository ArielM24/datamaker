import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

List<int> getNumbers(String str) {
  RegExp intRegexp = RegExp(r"\s*(\d+)\s*", multiLine: true);
  List<int> n = [];
  intRegexp.allMatches(str).forEach((element) {
    n.add(int.parse(element.group(0)));
  });
  return n;
}

String getName(String str) {
  return RegExp(r"Name=([a-zA-Z\ \dÀ-ÿ\u00f1\u00d1]+)", multiLine: true)
      .firstMatch(str)
      .group(1);
}

List<String> getTypes(String str) {
  List<String> types = [];
  RegExp type = RegExp(r"Type\d=([A-Z]+)");
  type.allMatches(str).forEach((element) {
    types.add(element.group(1));
  });
  return types;
}

List<int> getStats(String str) {
  RegExp rs = RegExp(r"BaseStats=(\d+,?)+", multiLine: true);
  return getNumbers(rs.firstMatch(str).group(0));
}

List<int> getEvs(String str) {
  RegExp rs = RegExp(r"EffortPoints=(\d+,?)+", multiLine: true);
  return getNumbers(rs.firstMatch(str).group(0));
}

int getHappiness(String str) {
  RegExp exp = RegExp(r"Happiness=(\d+)", multiLine: true);
  return int.parse(exp.firstMatch(str).group(1));
}

List<String> getAbilities(String str) {
  List<String> h = [];
  RegExp exp = RegExp(r"Abilities=([A-Z]+),?([A-Z]+)?");
  exp.allMatches(str).forEach((element) {
    for (int i = 1; i <= element.groupCount; i++) {
      var match = element.group(i);
      if (match != null) {
        h.add(match);
      }
    }
  });
  return h;
}

String getHiddenAbi(String str) {
  try {
    return RegExp(r"HiddenAbility=([A-Z]+)", multiLine: true)
        .firstMatch(str)
        .group(1);
  } catch (Exception) {
    return "";
  }
}

List<List> getMoves(String str) {
  List<List> m = [];
  RegExp exp = RegExp(r"Moves=(\d+,[A-Z]+,?)+", multiLine: true);
  exp.allMatches(str).forEach((element) {
    String s = element.group(0);
    RegExp(r"(\d+,[A-Z]+,?)", multiLine: true).allMatches(s).forEach((e) {
      m.add(e.group(0).split(",")..removeWhere((element) => element == ""));
    });
  });
  return m;
}

List<String> getEggMoves(String str) {
  List<String> moves = [];
  RegExp exp = RegExp(r"EggMoves=([A-Z],?)+", multiLine: true);
  exp.allMatches(str).forEach((element) {
    RegExp(r"([A-Z]+,?)", multiLine: true)
        .allMatches(element.group(0))
        .forEach((e) {
      moves.add(e.group(0).replaceAll(",", ""));
    });
  });
  moves.removeWhere((element) => element.length < 2 || element == "");
  return moves;
}

String getCompatibility(String str) {
  return RegExp(r"Compatibility=([A-Za-z]+)", multiLine: true)
      .firstMatch(str)
      .group(1);
}

int getSteps(String str) {
  return int.parse(
      RegExp(r"StepsToHatch=(\d+)", multiLine: true).firstMatch(str).group(1));
}

String getPokedex(String str) {
  return RegExp(r"Pokedex=(.*)", multiLine: true).firstMatch(str).group(1);
}

List<List> getEvolutions(String str) {
  List<List> ev = [];
  RegExp exp = RegExp(r"Evolutions=(.*,.*,.*,?)+", multiLine: true);
  exp.allMatches(str).forEach((element) {
    String s = element.group(1);
    RegExp(r"(.*,.*,.*,?)", multiLine: true).allMatches(s).forEach((e) {
      List l = e.group(1).split(",");
      List aux = [];
      for (int i = 1; i < l.length + 1; i++) {
        aux.add(l[i - 1]);
        if ((i % 3) == 0) {
          ev.add(aux);
          aux = [];
        }
      }
    });
  });
  return ev;
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

Pokemon getPokemon(String pkmStr) {
  Pokemon p = Pokemon();
  List<String> data = LineSplitter().convert(pkmStr);
  p.number = getNumbers(data[0])[0];
  p.name = getName(pkmStr);
  p.types = getTypes(pkmStr);
  p.stats = getStats(pkmStr);
  p.evs = getEvs(pkmStr);
  p.happines = getHappiness(pkmStr);
  p.abilities = getAbilities(pkmStr);
  p.hiddenAbi = getHiddenAbi(pkmStr);
  p.moves = getMoves(pkmStr);
  p.eggMoves = getEggMoves(pkmStr);
  p.compability = getCompatibility(pkmStr);
  p.stepsToHatch = getSteps(pkmStr);
  p.pokedex = getPokedex(pkmStr);
  p.evolutions = getEvolutions(pkmStr);
  return p;
}

class Pokemon {
  int number, happines, stepsToHatch;
  String name, hiddenAbi, compability, pokedex;
  List types, abilities, eggMoves;
  List stats, evs;
  List iconBytes;
  List moves, evolutions;
  static Map colorTypes = {
    "GRASS": Color.fromARGB(255, 120, 200, 80),
    "POISON": Color.fromARGB(255, 160, 64, 160),
    "WATER": Color.fromARGB(255, 104, 144, 240),
    "FIRE": Color.fromARGB(255, 240, 128, 48),
    "FLYING": Color.fromARGB(255, 168, 144, 240),
    "ELECTRIC": Color.fromARGB(255, 248, 208, 48),
    "BUG": Color.fromARGB(255, 168, 184, 32),
    "NORMAL": Color.fromARGB(255, 168, 168, 120),
    "GROUND": Color.fromARGB(255, 224, 192, 104),
    "FAIRY": Color.fromARGB(255, 240, 182, 188),
    "ICE": Color.fromARGB(255, 157, 201, 199),
    "FIGHTING": Color.fromARGB(255, 192, 48, 40),
    "PSYCHIC": Color.fromARGB(255, 248, 88, 136),
    "DARK": Color.fromARGB(255, 112, 88, 72),
    "ROCK": Color.fromARGB(255, 184, 160, 57),
    "STEEL": Color.fromARGB(255, 184, 184, 208),
    "GHOST": Color.fromARGB(255, 112, 88, 152),
    "DRAGON": Color.fromARGB(255, 112, 56, 248)
  };
  Pokemon();
  Pokemon.fromJson(Map<String, dynamic> json) {
    this.number = json["number"];
    this.happines = json["happines"];
    this.stepsToHatch = json["stepsToHatch"];
    this.name = json["name"];
    this.hiddenAbi = json["hiddenAbi"];
    this.compability = json["compability"];
    this.pokedex = json["pokedex"];
    this.types = json["types"];
    this.abilities = json["abilities"];
    this.eggMoves = json["eggMoves"];
    this.stats = json["stats"];
    this.evs = json["evs"];
    this.iconBytes = json["iconBytes"];
    this.moves = json["moves"];
    this.evolutions = json["evolutions"];
  }

  @override
  String toString() {
    return "pokemon:\n$number\n$name\n$types\n$stats"
        "\n$evs"
        "\n$happines\n$abilities\n$hiddenAbi\n"
        "$compability\n$stepsToHatch\n$pokedex";
  }

  Map<String, dynamic> toJson() => {
        "number": this.number,
        "happines": this.happines,
        "stepsToHatch": this.stepsToHatch,
        "name": this.name,
        "hiddenAbi": this.hiddenAbi,
        "compability": this.compability,
        "pokedex": this.pokedex,
        "types": this.types,
        "abilities": this.abilities,
        "eggMoves": this.eggMoves,
        "stats": this.stats,
        "evs": this.evs,
        "iconBytes": this.iconBytes,
        "moves": this.moves,
        "evolutions": this.evolutions
      };
  static Future<List<Pokemon>> readPokemonFile(String gameFolder) async {
    List<Pokemon> pkm = [];
    File f = File(gameFolder + "/PBS/pokemon.txt");
    print(f.path);
    var str = await f.readAsString();
    List l = str.split("[");
    l.removeAt(0);
    l.forEach((element) {
      pkm.add(getPokemon(element));
    });
    return await _addIcons(gameFolder, pkm);
  }

  static Future<List<Pokemon>> _addIcons(
      String gameFolder, List<Pokemon> pkm) async {
    for (int i = 0; i < pkm.length; i++) {
      pkm[i].iconBytes = await getIconbytes(gameFolder, pkm[i].number);
    }
    return pkm;
  }

  static Future writePokemonJson(String path, List<Pokemon> pkm) async {
    File fout = File(path);
    await fout.create(recursive: true);
    Map<String, dynamic> mpkm = {"Pokemon": pkm};
    String rawJson = jsonEncode(mpkm);
    await fout.writeAsString(rawJson);
  }

  static Future<String> readPokemonJson(String path) async {
    File f = File(path);
    String str = await f.readAsString();
    return str;
  }

  List<Color> getColors() {
    List<Color> colors = <Color>[];
    if (hasValidTypes()) {
      types.forEach((type) {
        colors.add(colorTypes[type]);
      });
    } else {
      colors.add(colorTypes["NORMAL"]);
    }
    if (colors.length < 2) {
      colors.add(colors[0]);
    }
    return colors;
  }

  List<Widget> getTypesImages() {
    var imgs = <Widget>[];
    if (hasValidTypes()) {
      types.forEach((type) {
        imgs.add(Padding(
          padding: const EdgeInsets.all(5.0),
          child: Image.asset("assets/${type.toLowerCase()}.png"),
        ));
      });
    } else {
      imgs.add(Padding(
        padding: const EdgeInsets.all(5.0),
        child: Image.asset("assets/normal.png"),
      ));
    }

    return imgs;
  }

  bool hasValidTypes() {
    bool valid = true;
    types.forEach((type) {
      valid &= colorTypes.keys.contains(type);
    });
    return valid;
  }

  List moveLevels(int pos) {
    List levels = [];
    moves.forEach((move) {
      levels.add(move[pos]);
    });
    return levels;
  }

  Uint8List getIconBytes() {
    return Uint8List.fromList(
        iconBytes.map((e) => int.parse(e.toString())).toList());
  }
}

class dataContainer {
  static List<Pokemon> pkmData;
  static int selected = 0;
  static Pokemon selection() {
    return pkmData[selected];
  }

  static void search(String name) {
    int exist = pkmData.indexWhere((pkm) => pkm.name == name);
    if (exist > -1) {
      selected = exist;
    } else {
      selected = 0;
    }
  }
}
