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
  aux.add(m[1]);
  aux.add(m[2]);
  aux.add(m[4]);
  aux.add(m[5]);
  aux.add(m[6]);
  aux.add(m[7]);
  aux.add(m[8]);
  aux.add(m[9]);
  String str = "";
  for (int i = 13; i < m.length; i++) {
    str = str + m[i];
  }
  aux.add(str);
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
