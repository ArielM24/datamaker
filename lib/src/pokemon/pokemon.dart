import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:DataMaker/src/pokemon/dataContainer.dart';

class Pokemon {
  int number, happines, stepsToHatch;
  String name, internalName, hiddenAbi, compability, weight, locations, pokedex;
  List types, abilities, eggMoves, tmMoves;
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
    this.internalName = json["internalName"];
    this.hiddenAbi = json["hiddenAbi"];
    this.compability = json["compability"];
    this.weight = json["weight"];
    this.locations = json["locations"];
    this.pokedex = json["pokedex"];
    this.types = json["types"];
    this.abilities = json["abilities"];
    this.eggMoves = json["eggMoves"];
    this.tmMoves = json["tmMoves"];
    this.stats = json["stats"];
    this.evs = json["evs"];
    this.iconBytes = json["iconBytes"];
    this.moves = json["moves"];
    this.evolutions = json["evolutions"];
  }

  List getEvolutiveLine() {
    List evo = [];
    evo.addAll(this.evolutions);
    this.evolutions.forEach((element) {
      var evols = DataContainer.pkmData.firstWhere(
          (p) =>
              p.name ==
              "${element[0][0]}${element[0].substring(1).toLowerCase()}",
          orElse: () => null);
      if (evols != null) {
        evo.addAll(evols.getEvolutiveLine());
      }
    });
    return evo;
  }

  int totalStats() {
    int total = 0;
    stats.forEach((element) {
      total += element;
    });
    return total;
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
        "internalName": this.internalName,
        "hiddenAbi": this.hiddenAbi,
        "compability": this.compability,
        "weight": this.weight,
        "locations": this.locations,
        "pokedex": this.pokedex,
        "types": this.types,
        "abilities": this.abilities,
        "eggMoves": this.eggMoves,
        "tmMoves": this.tmMoves,
        "stats": this.stats,
        "evs": this.evs,
        "iconBytes": this.iconBytes,
        "moves": this.moves,
        "evolutions": this.evolutions
      };

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
