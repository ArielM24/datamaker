import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:DataMaker/src/pokemon/pokemon.dart';
import 'package:flutter/material.dart';

class dataDetailView extends StatefulWidget {
  dataDetailView({Key key}) : super(key: key);

  @override
  createState() => _dataDetailViewState();
}

class _dataDetailViewState extends State<dataDetailView> {
  Pokemon pkm = dataContainer.selection();
  double evHeigth;
  int _currentIndex = 0;
  var _pages = [];

  @override
  Widget build(BuildContext context) {
    evHeigth = (90 * pkm.evolutions.length).toDouble();
    _pages = [_DataPage(), _EvolPage(), _MovesPage()];
    return Scaffold(
      appBar: AppBar(
          title: Text("${dataContainer.selection().name}"),
          backgroundColor: dataContainer.selection().getColors()[0],
          centerTitle: true,
          leading: IconButton(
            icon: Image.asset("assets/pokemon-go.png"),
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      body: _pages.elementAt(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        fixedColor: Colors.white,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: "Data"),
          BottomNavigationBarItem(icon: Icon(Icons.upgrade), label: "Evol"),
          BottomNavigationBarItem(icon: Icon(Icons.data_usage), label: "Moves"),
        ],
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _DataPage() {
    return ListView(
      children: _IconList() +
          _TypesList() +
          _HabilitiesList() +
          _StatsList() +
          _ExtraList(),
    );
  }

  List<Widget> _IconList() {
    return [
      _makeRoundedContainer(Text("#Número ${pkm.number}")),
      _makeRoundedContainer(SizedBox(
          width: 128,
          child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.fitHeight,
                    image: MemoryImage(pkm.getIconBytes()),
                  ),
                ),
              )))),
    ];
  }

  List<Widget> _TypesList() {
    return [
      _makeRoundedContainer(Column(
        children: <Widget>[Text("Tipo(s):")] +
            _makeListString(pkm.types) +
            <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: pkm.getTypesImages())
            ],
      )),
    ];
  }

  List<Widget> _HabilitiesList() {
    return [
      _makeRoundedContainer(Column(children: <Widget>[
        Text("Habilidades:"),
        _makeHabilitiesList(pkm.abilities + [pkm.hiddenAbi])
      ])),
    ];
  }

  List<Widget> _StatsList() {
    return [
      _makeRoundedContainer(Text("Stats base")),
      _makeRoundedContainer(Table(
        border: TableBorder.all(color: Colors.white),
        children: [
          TableRow(children: [
            Text("HP"),
            Text("ATK"),
            Text("DEF"),
            Text("SP"),
            Text("SATK"),
            Text("SDEF"),
          ]),
          TableRow(children: _makeListString(pkm.stats)),
        ],
      )),
    ];
  }

  List<Widget> _ExtraList() {
    return [
      _makeRoundedContainer(Text("Datos extra")),
      _makeRoundedContainer(Column(
        children: [
          Text("Felicidad base: ${pkm.happines}"),
          Text("Compatibilidad: ${pkm.compability}"),
          Text("Pasos para eclosionar: ${pkm.stepsToHatch}"),
          Text("Evs que suelta:"),
          Table(
            border: TableBorder.all(color: Colors.white),
            children: [
              TableRow(children: [
                Text("HP"),
                Text("ATK"),
                Text("DEF"),
                Text("SP"),
                Text("SATK"),
                Text("SDEF"),
              ]),
              TableRow(children: _makeListString(pkm.evs)),
            ],
          ),
          Text("Pokédex: ${pkm.pokedex}"),
        ],
      ))
    ];
  }

  Widget _EvolPage() {
    return ListView(
      children: [
        _makeRoundedContainer(Text("#Número ${pkm.number}")),
        _makeRoundedContainer(SizedBox(
            width: 128,
            child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.fitHeight,
                      image: MemoryImage(pkm.getIconBytes()),
                    ),
                  ),
                )))),
        _makeRoundedContainer(Text("Evoluciones")),
        Column(
          children: _makeEvolutionsList(),
        ),
      ],
    );
  }

  Widget _MovesPage() {
    return ListView(
      children: [
        _makeRoundedContainer(Text("#Número ${pkm.number}")),
        _makeRoundedContainer(SizedBox(
            width: 128,
            child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.fitHeight,
                      image: MemoryImage(pkm.getIconBytes()),
                    ),
                  ),
                )))),
        _makeRoundedContainer(Column(
          children: [
            Text("Movimientos:"),
            Table(
                columnWidths: {
                  0: FlexColumnWidth(3),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(15)
                },
                border: TableBorder.all(
                  color: Colors.white,
                ),
                children: _movesRows(pkm.moves)),
            Text("TMs"),
            Table(
              columnWidths: {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(10),
              },
              border: TableBorder.all(color: Colors.white),
              children: _movesRows(pkm.tmMoves.map((e) => [e]).toList()),
            ),
            Text("Huevo:"),
            Table(
                columnWidths: {
                  0: FlexColumnWidth(3),
                  1: FlexColumnWidth(10),
                },
                border: TableBorder.all(color: Colors.white),
                children: _movesRows(pkm.eggMoves.map((e) => [e]).toList())),
          ],
        )),
      ],
    );
  }

  List<TableRow> _movesRows(List moves) {
    var rows = <TableRow>[];
    if (moves.isNotEmpty) {
      if (moves[0].length == 2) {
        rows.add(
            TableRow(children: [Text("Info"), Text("Nivel"), Text("Nombre")]));
      } else if (moves[0].length == 1) {
        rows.add(TableRow(children: [Text("Info"), Text("Nombre")]));
      }
    }
    moves.forEach((move) {
      int index = move.length > 1 ? 1 : 0;
      rows.add(TableRow(
          children: <Widget>[
                RaisedButton(
                  onPressed: () => _showMoveData(move[index]),
                  child: Icon(Icons.more_horiz),
                )
              ] +
              _makeListString(move)
                  .map((e) => GestureDetector(
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Center(child: e),
                      ),
                      onTap: () => _showMoveData(move[index])))
                  .toList()));
    });
    return rows;
  }

  _showMoveData(String move) {
    showAlertDialog(
        context: context, message: _moveStr(dataContainer.pkmMoves[move]));
  }

  String _moveStr(List move) {
    return "${move[1]}\n"
        "Potencia: ${move[2] == '0' ? '-' : move[2]}\n"
        "Tipo: ${move[3]}\n"
        "Categoría: ${move[4]}\n"
        "Presición: ${move[5] == '0' ? '-' : move[5]}\n"
        "PPs: ${move[6]}\n"
        "Probabilidad de efecto: ${move[7] == '0' ? '-' : move[7]}\n"
        "Descripción: ${move[8]}\n";
  }

  List<Widget> _makeListString(List str) {
    var l = <Widget>[];
    str.forEach((element) {
      l.add(Text("$element"));
    });
    return l;
  }

  Widget _makeRoundedContainer(Widget wd) {
    return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.bottomRight,
                end: Alignment.bottomCenter,
                colors: pkm.getColors()),
            borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.all(5),
        alignment: Alignment.center,
        child: wd);
  }

  Widget _makeHabilitiesList(List habilities) {
    List<TableRow> rows = [];
    habilities.forEach((element) {
      rows.add(TableRow(children: [
        GestureDetector(
          child: Padding(
            padding: const EdgeInsets.only(top: 5, bottom: 5),
            child: Center(child: Text(element)),
          ),
          onTap: () {
            showAlertDialog(
                context: context,
                message: "${abilityStr(dataContainer.pkmAbilities[element])}");
          },
        )
      ]));
    });
    rows.insert(
        rows.length - 1, TableRow(children: [Center(child: Text("Huevo:"))]));
    return Table(
      border: TableBorder.all(color: Colors.white),
      children: rows,
    );
  }

  String abilityStr(List ability) {
    return "${ability[1]}\n"
        "Descripción: ${ability[2]}";
  }

  List<Widget> _makeEvolutionsList() {
    var tiles = <Widget>[];
    var evolutions = pkm.getEvolutiveLine();
    for (int i = 0; i < evolutions.length; i++) {
      String name = _normalizeName(evolutions[i][0]);
      tiles.add(
        GestureDetector(
            child: _makeRoundedContainer(
              Row(
                children: [
                  SizedBox(
                    width: 210,
                    child: ListTile(
                        title: Text(evolutions[i][0]),
                        subtitle:
                            Text("${evolutions[i][1]} ${evolutions[i][2]}"),
                        onTap: () => _navigateEvol(context, name)),
                  ),
                  _iconEvol(name),
                ],
              ),
            ),
            onTap: () => _navigateEvol(context, name)),
      );
    }
    return tiles;
  }

  String _normalizeName(String name) {
    if (name == "PORYGONZ") {
      name = "Porygon-Z";
    } else {
      name = "${name[0]}${name.substring(1).toLowerCase()}";
    }
    return name;
  }

  Widget _iconEvol(String name) {
    return SizedBox(
      width: 48,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.fitHeight,
                  alignment: Alignment.centerLeft,
                  image: MemoryImage(
                      dataContainer.getPokemon(name).getIconBytes()))),
        ),
      ),
    );
  }

  _navigateEvol(BuildContext context, String name) {
    dataContainer.search(name);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => dataDetailView()));
  }
}
