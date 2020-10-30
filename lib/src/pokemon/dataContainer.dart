import 'package:DataMaker/src/pokemon/pokemon.dart';

class DataContainer {
  static List<Pokemon> pkmData;
  static int selected = 0;
  static Map<String, List> pkmMoves;
  static Map<String, List> pkmAbilities;
  static Map<String, List> pkmLocations;
  static Map<String, List> pkmTypes;
  static int searching = 0;
  static bool hasSearched = false;
  static String predecesor;
  static Pokemon selection() {
    return pkmData[selected];
  }

  static void search(String name, [bool internal = false]) {
    int exist;
    if (!internal) {
      exist = pkmData.indexWhere((pkm) => pkm.name == name);
    } else {
      exist = pkmData.indexWhere((pkm) => pkm.internalName == name);
    }
    if (exist > -1) {
      selected = exist;
    } else {
      selected = 0;
    }
  }

  static Pokemon getPokemon(String name) {
    int exist = pkmData.indexWhere((pkm) => pkm.name == name);
    if (exist > -1) {
      return pkmData[exist];
    } else {
      return pkmData.first;
    }
  }

  static List<String> searchStats(int stats, [int inferior = 0, superior = 0]) {
    return pkmData
        .where((pkm) => (pkm.totalStats() >= (stats - inferior) &&
            pkm.totalStats() <= (stats + superior)))
        .map((p) => p.name)
        .toList();
  }
}
