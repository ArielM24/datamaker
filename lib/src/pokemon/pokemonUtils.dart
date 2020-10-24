import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:DataMaker/src/pokemon/pokemon.dart';

List<int> getNumbers(String str) {
  RegExp intRegexp = RegExp(r"\s*(\d+)\s*", multiLine: true);
  List<int> n = [];
  intRegexp.allMatches(str).forEach((element) {
    n.add(int.parse(element.group(0)));
  });
  return n;
}

String getName(String str) {
  return RegExp(r"Name=([a-zA-Z\ \dÀ-ÿ\u00f1\u00d1\-]+)", multiLine: true)
      .firstMatch(str)
      .group(1);
}

String getInternalName(String str) {
  return RegExp(r"InternalName=([a-zA-Z\ \dÀ-ÿ\u00f1\u00d1\-]+)",
          multiLine: true)
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
  RegExp exp = RegExp(r"Moves=(\d+,[A-Z0-9]+,?)+", multiLine: true);
  exp.allMatches(str).forEach((element) {
    String s = element.group(0);
    RegExp(r"(\d+,[A-Z0-9]+,?)", multiLine: true).allMatches(s).forEach((e) {
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
  return RegExp(r"Compatibility=([A-Za-z0-9,]+)", multiLine: true)
      .firstMatch(str)
      .group(1);
}

String getWeight(String str) {
  return RegExp(r"Weight=([A-Za-z0-9,\.]+)", multiLine: true)
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
  p.internalName = getInternalName(pkmStr);
  p.types = getTypes(pkmStr);
  p.stats = getStats(pkmStr);
  p.evs = getEvs(pkmStr);
  p.happines = getHappiness(pkmStr);
  p.abilities = getAbilities(pkmStr);
  p.hiddenAbi = getHiddenAbi(pkmStr);
  p.moves = getMoves(pkmStr);
  p.eggMoves = getEggMoves(pkmStr);
  p.compability = getCompatibility(pkmStr);
  p.weight = getWeight(pkmStr);
  p.stepsToHatch = getSteps(pkmStr);
  p.pokedex = getPokedex(pkmStr);
  p.evolutions = getEvolutions(pkmStr);
  return p;
}

Map<String, List> getAbilitiesMap(List<String> pkmAbilities) {
  Map<String, List> abilities = {};
  for (var a in pkmAbilities) {
    var ability = getAbilityList(a);
    abilities[ability[0]] = ability;
  }
  return abilities;
}

List getAbilityList(String ability) {
  var a = ability.split(",");
  List aux = [];
  aux.add(a[1]);
  aux.add(a[2]);
  aux.add(a.sublist(3).join());
  return aux;
}

Map<String, List> getLocationsMap(List<String> pkmLocations) {
  Map<String, List> locations = {};
  for (int i = 1; i < pkmLocations.length; i += 2) {
    var location = getLocationList(pkmLocations[i]);
    if (locations.keys.contains(location[0])) {
      locations[location[0]].addAll(location.sublist(1));
    } else {
      locations[location[0]] = location;
    }
  }
  return locations;
}

List getLocationList(String location) {
  List lines = LineSplitter.split(location).toList();
  List aux = [];
  String method;
  aux.add(lines[0].trim());
  for (int i = 2; i < lines.length; i++) {
    List p = lines[i].split(",");
    if (p.length == 1) {
      method = p[0];
    } else if (p.length > 2) {
      aux.add(p[0]);
      aux.add(method);
      aux.add(p[1]);
      aux.add(p[2]);
    }
  }
  return aux;
}

Map<String, List> getMovesMap(List<String> pkmMoves) {
  Map<String, List> moves = {};
  for (var m in pkmMoves) {
    var move = getMoveList(m);
    moves[move[0]] = move;
  }
  return moves;
}

List getMoveList(String move) {
  var m = move.split(",");
  List aux = [];
  for (int i = 1; i < 10; i++) {
    if (i != 3) {
      aux.add(m[i]);
    }
  }
  aux.add(m.sublist(13).join());
  return aux;
}

Map<String, List<String>> getTMs(List<String> lines) {
  Map<String, List<String>> tms = {};
  bool move = false;
  String mv;
  lines.forEach((line) {
    if (line.startsWith("[")) {
      move = true;
      mv = line.substring(1, line.length - 1);
    } else if (move) {
      List pkm = line.split(",");
      pkm.forEach((p) {
        if (tms.containsKey(p)) {
          tms[p] += [mv];
        } else {
          tms[p] = [mv];
        }
      });
      move = false;
    }
  });
  return tms;
}

List<Pokemon> addTms(Map<String, List<String>> tms, List<Pokemon> pkm) {
  for (int i = 0; i < pkm.length; i++) {
    String name = pkm[i].name.toUpperCase();
    name = name.replaceAll(" ", "");
    if (name == "PORYGON-Z") {
      name = "PORYGONZ";
    } else if (name == "CÓDIGOCERO") {
      name = "TYPENULL";
    }
    pkm[i].tmMoves = (tms[name] == null) ? [] : tms[name];
  }
  return pkm;
}

addLocations(Map<String, List<dynamic>> locations, List<Pokemon> pkm) {
  print("add");
  for (int i = 0; i < pkm.length; i++) {
    if (pkm[i].locations == null) {
      pkm[i].locations = "";
    }
    locations.forEach((key, value) {
      if (value.contains(pkm[i].internalName)) {
        int index = value.indexOf(pkm[i].internalName);
        if (pkm[i].internalName == "GOLDUCK") {
          print(value);
        }
        pkm[i].locations +=
            "$key: ${value[index + 1]} (${value[index + 2]}, ${value[index + 3]}) lv\n";
      }
    });
  }
  return pkm;
}
